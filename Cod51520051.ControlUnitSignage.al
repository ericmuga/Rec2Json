codeunit 51520051 "Control Unit Signage"

{
    var
        Amount: Decimal;

    procedure SignInvoices(Rec: Record "Sales Header")
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        RequestObject: JsonObject;
        ResponseText: Text;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        Content: HttpContent;
        TextContent: Text;
        Path: Text;
        Terminal: Text;
        Options: JsonObject;
        Trial: Text;
        J: JsonObject;
        CashierName: Text;
        AssignedInvoiceNo: Text;
        JT: JsonToken;
        QR: Text;
        Setup: Record 51521060;
        Cust: Record Customer;
        INS: InStream;
        OUTS: OutStream;
        SINV: Record "Sales Invoice Header";
        InvOrCN: Code[10];
        GLS: Record "General Ledger Setup";
        LogCU: Codeunit "Device Signage Logs";
        logs: Record "Device Signage Log";
        LogEntryNo: Integer;





    begin
        // Message('here');



        with Rec do begin
            Rec.CUInvoiceNo := '';
            Rec.CUNo := '';
            Rec.SignTime := '';

            GLS.GET;
            if (Rec."Posting Date" < GLS."Allow Posting From") then
                Error('The Posting date is not within the allowed range of posting dates');

            if (Rec."Posting Date" > GLS."Allow Posting To") then
                Error('The Posting date is not within the allowed range of posting dates');

            if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then
                InvOrCN := 'SCN'
            else
                InvOrCN := 'SIN';

            if Not (Setup.FindFirst()) then begin
                Message('QR Code Setup is empty \ Please modify the settings');
                Page.Run(51520050);

            end;

            Terminal := 'invoices';



            RequestObject.Add('invoiceType', 0);
            if Rec."Document Type" In [Rec."Document Type"::Invoice, Rec."Document Type"::Order] then
                RequestObject.Add('transactionType', 0)
            else
                RequestObject.Add('transactionType', 1);

            //get relevant invoice number

            RequestObject.Add('cashier', CopyStr(UserId, StrPos(UserId, '\') + 1, StrLen(UserId)));
            RequestObject.Add('items', GetLineItems(Rec));

            if Rec."Document Type" In [Rec."Document Type"::Invoice, Rec."Document Type"::Order] then begin

                RequestObject.Add('lines', GetLinesMember());
                RequestObject.Add('payment', GetPaymentArray(Rec));
                RequestObject.Add('TraderSystemInvoiceNumber', InvOrCN + DELCHR(FORMAT(Rec."No."), '=', DELCHR(FORMAT(Rec."No."), '=', '1234567890')));
                if Cust.Get("Sell-to Customer No.") then
                    if Cust.ExemptionNo <> '' then
                        RequestObject.Add('ExemptionNumber', Cust.ExemptionNo);
                if (GetJsonTextField(GetBuyerDetails(Rec), 'pinOfBuyer') <> 'P000000000P') then
                    RequestObject.Add('buyerId', GetBuyerDetails(Rec));

            end
            else begin
                IF NOT SINV.GET(Rec."Applies-to Doc. No.") then Error('The applied Invoice No. does not exist');
                RequestObject.Add('relevantNumber', SINV.CUInvoiceNo);
            end;
            RequestObject.WriteTo(TextContent);
            TextContent := TextContent.Replace(' ', '');
            Content.WriteFrom(TextContent);
            Content.GetHeaders(ContentHeaders);
            ContentHeaders.Clear();
            ContentHeaders.Add('Content-Type', 'application/json');

            Request.Content := Content;
            Request.Method := 'POST';
            Path := resolveControlUnitIP(Rec, 1).ToLower() + Terminal;

            Request.SetRequestUri(Path);




            // IF ("Document Type" = Rec."Document Type"::"Credit Memo") then
            if StrPos(UserId, 'EMUGA') <> 0 then begin
                if NOT (Confirm(Format(TextContent))) then exit;
            end;
            if Client.Send(Request, Response) then begin

                if Rec."Document Type" = rec."Document Type"::"Credit Memo" then
                    LogEntryNo := LogCU.InsertLogs(resolveControlUnitIP(Rec, 2),
                                     Logs."Document Type"::CreditNote,
                                     Rec."No.",
                                     CopyStr(TextContent, 1, 2048),
                                     '',
                                     false,
                                     CurrentDateTime,
                                     0DT)
                else
                    LogEntryNo := LogCU.InsertLogs(resolveControlUnitIP(Rec, 2),
                                     Logs."Document Type"::Invoice,
                                     Rec."No.",
                                     CopyStr(TextContent, 1, 2048),
                                     '',
                                     false,
                                     CurrentDateTime,
                                     0DT);
                Commit();



                if Response.IsSuccessStatusCode() then begin
                    Response.Content().ReadAs(ResponseText);

                    logs.GET(LogEntryNo);
                    logs.Response := ResponseText;
                    logs."Response DateTime" := CurrentDateTime;
                    logs.Modify();
                    Commit();



                    clear(J);
                    Clear(Rec.CUInvoiceNo);
                    J.ReadFrom(ResponseText);
                    // Message(Format(J));

                    Rec.CUInvoiceNo := GetJSONValue(J, 'mtn');
                    Rec.CUNo := GetJSONValue(J, 'msn');
                    Rec.SignTime := GetJSONValue(J, 'DateTime');
                    Rec.Modify();
                    QR := Rec.CUInvoiceNo + '.png';
                    if (GenerateQRCode(Setup.ImageServiceUri, GetJSONValue(J, 'mtn'))) = 'Success' then begin
                        Rec.CalcFields(QRCode);
                        Rec.QRCode.Import(Setup.QRCodeStorage + QR);
                    end
                    else
                        Error('An error was encountered in generating the QR Code image');

                end
                else begin

                    logs.GET(LogEntryNo);
                    logs.Response := Format(Response.HttpStatusCode);
                    logs."Response DateTime" := CurrentDateTime;
                    logs.Error := true;
                    logs.Modify();
                    Commit();


                    Rec.CUInvoiceNo := '';
                    Rec.CUNo := '';
                    Rec.SignTime := '';
                    Response.Content().ReadAs(ResponseText);
                    J.ReadFrom(ResponseText);
                    Message(Format(J));
                    Error('Request failed because of %1 ', Response.ReasonPhrase());
                end;

                Rec.Modify();

            end;
            // exit(true);
        end;
    end;

    procedure GenerateQRCode(Uri: Text; CUInvNo: Text): Text;
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Path: Text;
        Req: JsonObject;
    begin
        Path := Uri + CUInvNo + '.';
        // Message(Path);
        if Client.GET(Path, Response) then
            if Response.IsSuccessStatusCode() then begin
                exit('Success');
            end
            else
                Error('Request failed because of %1 ', Response.ReasonPhrase());
    end;

    procedure CheckReturnReason(Rec: Record "Sales Header")
    var
        Lines: Record "Sales Line";
    begin

        lines.SetRange("Document Type", lines."Document Type"::"Credit Memo");
        lines.SetRange("Document No.", Rec."No.");
        lines.SetRange(Type, Lines.Type::Item);
        Lines.SetFilter("No.", '<>%1', '');
        Lines.SetRange("Return Reason Code", '');
        if lines.FindFirst() then Error('You have not entered a return reason in one or more lines');

    end;

    // procedure checkSalesPersonCode (SH: Record "Sales Header")
    // var
    //  SL: Record "Sales Line";
    //  begin
    //    SL.RESET;
    //    SL.SetRange("Document Type",SH."Document Type");
    //    SL.SetRange("Document No.",SH."No.");
    //    SL.SetFilter();
    //  end;

    local procedure GetJSONValue(J: JsonObject; member: Text): Text
    var
        JT: JsonToken;
        ReturnText: Text;

    begin
        IF J.Get(member, JT) then begin
            JT.WriteTo(ReturnText);
            exit(ReturnText.Replace('"', ''));
        end

        else
            Error(Format(J));

    end;

    procedure GetPaymentArray(Rec: Record "Sales Header"): JsonArray
    var
        JA: JsonArray;
        JO: JsonObject;
        SL: Record "Sales Line";
        AMT: Decimal;
    begin

        JO.Add('amount', Round(Amount + 10, 0.01, '>'));
        JO.Add('paymentType', 'Cash');
        JA.Add(JO);
        exit(JA);
    end;

    procedure GetBuyerDetails(Rec: Record "Sales Header"): JsonObject
    var
        cust: Record Customer;
        JO: JsonObject;
        TextContent: Text[250];
    begin

        cust.Get(Rec."Bill-to Customer No.");
        JO.Add('buyerName', cust.Name.ToLower());
        IF cust.City = '' then
            JO.Add('buyerAddress', 'Blank Address') else
            JO.Add('buyerAddress', cust.City.ToLower());
        if cust."Phone No." = '' then
            JO.Add('buyerPhone', '+254000000000')
        else
            JO.Add('buyerPhone', DELCHR(FORMAT(cust."Phone No."), '=', DELCHR(FORMAT(cust."Phone No."), '=', '1234567890')));


        if cust."Telex Answer Back" <> '' then
            JO.Add('pinOfBuyer', cust."Telex Answer Back")
        else
            JO.Add('pinOfBuyer', 'P000000000P');
        exit(JO);


    end;


    procedure GetQRASTEXT(SalesInvHeader: Record "Sales Invoice Header") QRCodeText: Text
    var
        MyInStream: InStream;

    begin
        Clear(QRCodeText);
        SalesInvHeader.Calcfields("Work Description");
        If SalesInvHeader.QRCode.HasValue() then begin
            SalesInvHeader.QRCode.CreateInStream(MyInStream);
            MyInStream.Read(QRCodeText);
        end;
    end;

    local procedure resolveControlUnitIP(Rec: Record "Sales Header"; what: Integer): Text
    var
        CUUsers: Record 51521061;
        Setup: Record 51521060;
        SINV: Record "Sales Invoice Header";
    begin

        if (Rec."Document Type" = Rec."Document Type"::Invoice) then begin

            CUUsers.Reset();
            CUUsers.SetRange(UserID, UserId);
            if NOT CUUsers.FindFirst() then
                Page.Run(Page::"Control Unit Users");

            if NOT CUUsers.FindFirst() then
                Error('No users have been confifured with he control units')
            else begin
                Setup.Get(CUUsers."Control Unit No");
                if (what = 1) then exit(Setup."IP Address") else exit(Setup."CU No.");
            end;

        end
        else begin
            If NOT SINV.GET(Rec."Applies-to Doc. No.") then
                Error('The Applied document No. Could not be found')
            else begin
                IF NOT Setup.Get(SINV.CUNo) then
                    Error('The Control unit could not be found')
                else
                    exit(Setup."IP Address");
            end;

        end;
    end;

    procedure VerifyPIN(Rec: Record "Sales Header"): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        J: JsonObject;
        ResponseText: Text;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        Content: HttpContent;
        TextContent: Text;
        Path: Text;
        Terminal: Text;
        setup: Record "Control Unit Setup";

    begin
        Terminal := 'pin';

        Path := resolveControlUnitIP(Rec, 1).ToLower() + Terminal;
        setup.SetRange("IP Address", resolveControlUnitIP(Rec, 1));
        if setup.FindFirst() then TextContent := setup.PIN;

        TextContent := '0000';
        Content.WriteFrom(TextContent);
        Request.Content(Content);
        Request.Method('POST');
        Request.SetRequestUri(Path);

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseText);
                //save CU Invoice Numnber and CU serial Number, and Link
                // Message('100');
                exit(ResponseText);
            end
            else
                exit(Format(Response.HttpStatusCode));
    end;

    procedure GetLineItems(Rec: Record "Sales Header"): JsonArray
    var
        Lines: Record "Sales Line";
        Item: Record "Item";
        VATSetup: Record "VAT Posting Setup";
        JA: JsonArray;
        Items: JsonObject;
        UP: Decimal;
        UP2: Decimal;
        hs: Text;
        counter: Integer;
        IntegerPart: Code[20];
        DecimalPart: Code[20];
        dec: Decimal;
        MaxLength: Integer;
        CNLines: Record "Sales Line";
        CNSumProdLine: Decimal;
        INVSumProdLines: Decimal;
        INVLines: Record "Sales Invoice Line";
        CrNoteQuery: Query 50102;
        INVQuery: Query 50103;
        ItemRec: Record Item;
        Checker: Text[50];
        NoChecker: Code[50];
        VATCheck: Code[10];
        CNPrdSum: Decimal;
    // counter: Integer;
    begin
        // if StrPos(UserId, 'EMUGA') <> 0 then Message('GetLineItems Called');
        if (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Order]) then begin
            Lines.Reset;
            Lines.SETRANGE("Document No.", Rec."No.");
            Lines.SetRange("Document Type", Rec."Document Type");
            Lines.SetFilter("No.", '<>%1', '');
            Lines.SetFilter(Quantity, '<>%1', 0);
            counter := 0;
            Amount := 0;
            counter := 0;
            if Lines.Find('-') then
                Repeat
                    counter += 1;
                    Items.Add('name', CopyStr(Lines.Description, 1, 42));
                    Items.Add('quantity', Lines.Quantity);
                    UP := Round((Lines."Amount Including VAT" / Lines.Quantity), 0.000001);
                    Amount += ROUND(UP, 0.000001) * Lines.Quantity;
                    Items.Add('unitPrice', UP);
                    if (resolveHSCode(Lines."No.", Lines."VAT Identifier") = '') then
                        hs := ''
                    else
                        hs := resolveHSCode(Lines.Description, Lines."VAT Identifier");

                    if hs <> '' then
                        Items.Add('hsCode', hs);

                    JA.Add(Items);
                    Clear(Items);
                until Lines.Next() = 0;
        end
        else begin //credit notes
                   // if StrPos(UserId, 'EMUGA') <> 0 then Message('Credit note portion');
            Checker := '';
            CNPrdSum := 0;
            VATCheck := '';
            counter := 0;
            CNLines.Reset();
            CNLines.SetRange("Document No.", Rec."No.");
            CNLines.SetRange("Document Type", Rec."Document Type");
            CNLines.SetFilter("Amount Including VAT", '>%1', 0);
            CNLines.SetCurrentKey("No.");
            CNLines.SetAscending("No.", true);
            if CNLines.Find('-') then
                repeat
                    counter += 1;
                    if (Checker = '') then begin
                        //first line
                        Checker := CNLines.Description;
                        if (CNLines.Type = CNLines.Type::Item) then
                            NoChecker := CNLines."No.";
                        VATCheck := CNLines."VAT Identifier";
                        CNPrdSum += CNLines."Amount Including VAT";

                    end
                    else begin
                        if Checker = CNLines.Description then begin
                            CNPrdSum += CNLines."Amount Including VAT";
                        end
                        else begin
                            //push the previous line

                            Items.Add('totalAmount', ROUND(CNPrdSum - 0.10, 0.000001, '<'));
                            Items.Add('name', CopyStr(Checker, 1, 42));

                            ItemRec.Reset();
                            ItemRec.SetRange("No.", NoChecker);

                            if ItemRec.FindFirst() then
                                hs := resolveHSCode(ItemRec."No.", VATCheck)
                            else
                                hs := resolveHSCode(Checker, VATCheck);

                            if hs <> '' then Items.Add('hsCode', hs);
                            JA.Add(Items);
                            Clear(Items);

                            //reset variables
                            CNPrdSum := CNLines."Amount Including VAT";
                            Checker := CNLines.Description;
                            if (CNLines.Type = CNLines.Type::Item) then
                                NoChecker := CNLines."No.";
                            VATCheck := CNLines."VAT Identifier";
                        end;
                    end;

                    //if first line is also last line

                    Checker := CNLines.Description;
                    if (CNLines.Type = CNLines.Type::Item) then
                        NoChecker := CNLines."No.";
                    VATCheck := CNLines."VAT Identifier";

                    if (CNLines.Count - counter = 0) then begin
                        Items.Add('totalAmount', ROUND(CNPrdSum - 0.10, 0.000001, '<'));
                        Items.Add('name', CopyStr(Checker, 1, 42));
                        ItemRec.Reset();
                        ItemRec.SetRange("No.", NoChecker);
                        if ItemRec.FindFirst() then
                            hs := resolveHSCode(ItemRec."No.", VATCheck)
                        else
                            hs := resolveHSCode(Checker, VATCheck);
                        if hs <> '' then
                            Items.Add('hsCode', hs);

                        JA.Add(Items);
                        Clear(Items);
                    end;



                until CNLines.Next() = 0;

            /*

               CrNoteQuery.SetRange(Document_No_, Rec."No.");
               CrNoteQuery.Open();
               while CrNoteQuery.Read() do begin
                   // if StrPos(UserId, 'EMUGA') <> 0 then Message(CrNoteQuery.No_);
                   INVQuery.SetRange(Document_No_, Rec."Applies-to Doc. No.");
                   INVQuery.SetRange(Description, CrNoteQuery.Description);
                   INVQuery.Open();
                   if (INVQuery.Read()) and (CrNoteQuery.Amount_Including_VAT > 0) then begin
                       // if UserId = 'EMUGA' then Message(CrNoteQuery.No_);
                       // if StrPos(UserId, 'EMUGA') <> 0 then Message('item found in invoice');
                       if (CrNoteQuery.Amount_Including_VAT <= INVQuery.Amount_Including_VAT) then
                           Items.Add('totalAmount', ROUND(CrNoteQuery.Amount_Including_VAT - 0.01, 0.000001, '<'))
                       else
                           Items.Add('totalAmount', ROUND(CrNoteQuery.Amount_Including_VAT - 0.10, 0.000001, '<'));

                       Items.Add('name', CopyStr(CrNoteQuery.Description, 1, 42));

                       IF NOT ItemRec.Get(CrNoteQuery.No_) then begin
                           ItemRec.SetRange(Description, CrNoteQuery.Description);
                           if ItemRec.FindFirst() then;
                       end;


                       hs := resolveHSCode(ItemRec."No.", CrNoteQuery.VAT_Identifier);
                       if hs <> '' then
                           Items.Add('hsCode', resolveHSCode(ItemRec."No.", CrNoteQuery.VAT_Identifier));

                       JA.Add(Items);
                       Clear(Items);

                   end;
                   INVQuery.Close();
                   Clear(INVQuery);
               end;
               CrNoteQuery.Close();
               Clear(CrNoteQuery);
           end;
           */
        end;
        exit(JA);
    end;


    local procedure resolveHSCode(ItemNo: Code[50]; VATId: Text): Code[20]
    var
        HSCodes: Record "HS Codes";
        HSCode: Code[20];
    begin
        // HSCode := '';
        HSCodes.Reset();
        HSCodes.SetRange("Item No.", CopyStr(ItemNo, 1, 20));
        HSCodes.SetRange("VAT Identifier", VATId);
        if HSCodes.FindFirst() then
            exit(HSCodes.HSCode)
        else
            exit('');

    end;

    procedure GetLinesMember(): JsonArray
    var
        JA: JsonArray;
        JO: JsonObject;
    begin
        JO.Add('lineType', 'Text');
        JO.Add('alignment', 'bold center');
        JO.Add('format', 'Bold');
        JO.Add('value', 'Thanks for your business!');
        JA.Add(JO);
        exit(JA);
    end;

    procedure GetJsonTextField(O: JsonObject; Member: Text): Text
    var
        Result: JsonToken;
    begin
        if O.Get(Member, Result) then begin
            exit(Result.AsValue().AsText());
        end
        else
            exit('NotFound');

    end;



}



