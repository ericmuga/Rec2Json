codeunit 51520055 "Control Unit Signage CN"

{
    Permissions = tabledata "Sales Cr.Memo Header" = rmid;

    var

    var
        Amount: Decimal;

    procedure SignInvoices(Rec: Record "Sales Cr.Memo Header")
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
        SCRMH: Record "Sales Cr.Memo Header";
        SINV: Record "Sales Invoice Header";
        InvOrCN: Code[10];
        uploadCU: Codeunit 51520053;
        LogCU: Codeunit "Device Signage Logs";
        logs: Record "Device Signage Log";
        LogEntryNo: Integer;






    begin
        with Rec do begin
            Rec.CUInvoiceNo := '';
            Rec.CUNo := '';
            Rec.SignTime := '';
            InvOrCN := 'SCN';

            if Not (Setup.FindFirst()) then begin
                Message('QR Code Setup is empty \ Please modify the settings');
                Page.Run(51520050);

            end;

            Terminal := 'invoices';
            CashierName := CopyStr(UserId, 15, StrLen(UserId));

            RequestObject.Add('invoiceType', 0);
            RequestObject.Add('transactionType', 1);
            RequestObject.Add('cashier', CashierName);
            RequestObject.Add('items', GetLineItems(Rec));
            IF NOT SINV.GET(Rec."Applies-to Doc. No.") then Error('The applied Invoice No. does not exist');
            RequestObject.Add('relevantNumber', SINV.CUInvoiceNo);

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

            // If Confirm(Format(TextContent)) then
            if StrPos(UserId, 'EMUGA') <> 0 then begin
                if NOT (Confirm(Format(TextContent))) then exit;
            end;
            if Client.Send(Request, Response) then begin


                LogEntryNo := LogCU.InsertLogs(resolveControlUnitIP(Rec, 2),
                                               Logs."Document Type"::CreditNote,
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

                    Response.Content().ReadAs(ResponseText);
                    J.ReadFrom(ResponseText);
                    //Message(Format(J));
                    Rec.CUInvoiceNo := GetJSONValue(J, 'mtn');
                    Rec.CUNo := GetJSONValue(J, 'msn');
                    Rec.SignTime := GetJSONValue(J, 'DateTime');
                    Rec.Modify();
                    Commit();
                    QR := Rec.CUInvoiceNo + '.png';
                    if (GenerateQRCode(Setup.ImageServiceUri, GetJSONValue(J, 'mtn'))) = 'Success' then begin
                        Rec.CalcFields(QRCode);
                        Rec.QRCode.Import(Setup.QRCodeStorage + GetJSONValue(J, 'mtn') + '.png');
                    end
                    //uploadCU.uploadCR(Rec)
                    else
                        Error('An error was encountered in generating the QR Code image');

                end
                else begin
                    Response.Content().ReadAs(ResponseText);

                    logs.GET(LogEntryNo);
                    logs.Response := Format(Response.HttpStatusCode);
                    logs."Response DateTime" := CurrentDateTime;
                    logs.Error := true;
                    logs.Modify();
                    Commit();

                    J.ReadFrom(ResponseText);
                    Rec.CUInvoiceNo := '';
                    Rec.CUNo := '';
                    Rec.SignTime := '';
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
        JO.Add('amount', Amount);
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

    local procedure resolveControlUnitIP(Rec: Record "Sales Cr.Memo Header"; what: Integer): Text
    var
        CUUsers: Record 51521061;
        Setup: Record 51521060;
        SINV: Record "Sales Invoice Header";
    begin

        If NOT SINV.GET(Rec."Applies-to Doc. No.") then
            Error('The Applied document No. Could not be found')
        else begin
            IF NOT Setup.Get(SINV.CUNo) then
                Error('The Control unit could not be found')
            else
                if (what = 1) then exit(Setup."IP Address") else exit(Setup."CU No.");
        end;






    end;

    procedure VerifyPIN(Rec: Record "Sales Cr.Memo Header"): Text
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

    begin
        Terminal := 'pin';

        Path := resolveControlUnitIP(Rec, 1).ToLower() + Terminal;
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

    procedure GetLineItems(Rec: Record "Sales Cr.Memo Header"): JsonArray
    var
        Lines: Record "Sales Cr.Memo Line";
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
        CNLines: Record "Sales Cr.Memo Line";
        CNSumProdLine: Decimal;
        INVSumProdLines: Decimal;
        INVLines: Record "Sales Invoice Line";
        ItemRec: Record Item;
    begin
        Lines.Reset;
        Lines.SETRANGE("Document No.", Rec."No.");
        Lines.SetFilter("No.", '<>%1', '');
        Lines.SetFilter(Quantity, '<>%1', 0);

        counter := 0;
        Amount := 0;
        if Lines.Find('-') then
            Repeat
                if (Lines."No." <> '41990') and (Lines."No." <> 'B40900') and (Lines."Amount Including VAT" > 0) then begin


                    counter += 1;
                    Items.Add('name', CopyStr(Lines.Description, 1, 42));
                    ///check that amount never exceeds invoice amount
                    //check that the line does not exceed total lines amount
                    CNLines.RESet;
                    CNLines.SetRange("Document No.", Lines."Document No.");
                    CNLines.SetRange(Description, Lines.Description);
                    CNSumProdLine := 0;
                    if CNLines.Find('-') then
                        repeat
                            CNSumProdLine += CNLines."Amount Including VAT";
                        until CNLines.Next() = 0;

                    INVLines.Reset();
                    INVLines.SetRange("Document No.", Rec."Applies-to Doc. No.");
                    INVLines.SetRange(Description, Lines.Description);
                    INVSumProdLines := 0;
                    if INVLines.Find('-') then
                        repeat
                            INVSumProdLines += INVLines."Amount Including VAT";
                        until INVLines.Next() = 0;

                    // if CNSumProdLine > INVSumProdLines then begin
                    //     CNLines.RESet;
                    //     CNLines.SetRange("Document No.", Lines."Document No.");
                    //     CNLines.SetRange(Description, Lines.Description);
                    //     CNSumProdLine := 0;
                    //     if CNLines.Find('-') then
                    //         repeat
                    //             CNLines.Validate("Unit Price", CNLines."Unit Price" - 0.01);
                    //             CNLines.Modify();
                    //         until CNLines.Next() = 0;
                    // end;


                    //

                    // if Lines."VAT %" <> 0 then
                    //     UP := Lines."Unit Price" * (1 + Lines."VAT %" / 100)
                    // else
                    //     UP := Lines."Unit Price";
                    //  UP := Round((Lines."Amount Including VAT" / Lines.Quantity), 0.00000001, '<');
                    // UP2 := Round((UP * Lines.Quantity), 0.01, '<');
                    // UP2 := Lines."Amount Including VAT";
                    // Items.Add('totalAmount', UP);
                    Items.Add('totalAmount', (ROUND(Lines."Amount Including VAT" - 0.1, 0.0000001, '<')));

                    IF NOT ItemRec.Get(Lines."No.") then begin
                        ItemRec.SetRange(Description, Lines.Description);
                        if ItemRec.FindFirst() then;
                    end;
                    hs := resolveHSCode(ItemRec."No.", Lines."VAT Identifier");
                    /* 
                        if hs <> '' then
                            Items.Add('hsCode', resolveHSCode(ItemRec."No.", Lines."VAT Identifier"));
                        */

                    if hs <> '' then
                        Items.Add('hsCode', hs);
                    JA.Add(Items);
                    Clear(Items);
                end;
            Until Lines.Next = 0;
        exit(JA);
    end;

    local procedure resolveHSCode(ItemNo: Code[20]; VATId: Text): Code[20]
    var
        HSCodes: Record "HS Codes";
        HSCode: Code[20];
    begin
        HSCode := '';
        HSCodes.Reset();
        HSCodes.SetRange("Item No.", ItemNo);
        HSCodes.SetRange("VAT Identifier", VATId);
        if HSCodes.FindFirst() then
            exit(HSCodes.HSCode);

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
        end;
    end;

}



