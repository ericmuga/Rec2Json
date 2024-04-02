codeunit 51520054 "Control Unit SignageINV"

{
    Permissions = tabledata "Sales Invoice Header" = rmid;

    var
        Amount: Decimal;

    procedure SignInvoices(Rec: Record "Sales Invoice Header")
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
        LogCU: Codeunit "Device Signage Logs";
        logs: Record "Device Signage Log";
        LogEntryNo: Integer;

    begin
        with Rec do begin

            Rec.CUInvoiceNo := '';
            Rec.CUNo := '';
            Rec.SignTime := '';

            case CompanyName of
                'RMK':
                    InvOrCN := 'RMSN';
                'FCL':
                    InvOrCN := 'FCSN';
                'CM':
                    InvOrCN := 'CMSN';
                'FLM':
                    InvOrCN := 'FMSN';

            end;


            if Not (Setup.FindFirst()) then begin
                Message('QR Code Setup is empty \ Please modify the settings');
                Page.Run(51520050);

            end;

            IF NOT Setup.FindFirst() then Error('Control Unit Setup table has not been initialized');


            Terminal := 'invoices';
            // CashierName := CopyStr(UserId, 15, StrLen(UserId));

            RequestObject.Add('invoiceType', 0);
            RequestObject.Add('transactionType', 0);

            //get relevant invoice number

            // RequestObject.Add('cashier', CashierName);
            RequestObject.Add('cashier', CopyStr(UserId, StrPos(UserId, '\') + 1, StrLen(UserId)));
            RequestObject.Add('items', GetLineItems(Rec));


            RequestObject.Add('lines', GetLinesMember());
            RequestObject.Add('payment', GetPaymentArray(Rec));
            RequestObject.Add('TraderSystemInvoiceNumber', InvOrCN + DELCHR(FORMAT(Rec."No."), '=', DELCHR(FORMAT(Rec."No."), '=', '1234567890')));
            if Cust.Get("Sell-to Customer No.") then
                if Cust.ExemptionNo <> '' then
                    RequestObject.Add('ExemptionNumber', Cust.ExemptionNo);
            if (GetJsonTextField(GetBuyerDetails(Rec), 'pinOfBuyer') <> 'P000000000P') then
                RequestObject.Add('buyer', GetBuyerDetails(Rec));
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
                //log the request
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
        J.Get(member, JT);
        JT.WriteTo(ReturnText);

        exit(ReturnText.Replace('"', ''));
        IF J.Get(member, JT) then begin
            JT.WriteTo(ReturnText);
            exit(ReturnText.Replace('"', ''));
        end

        else
            Error(Format(J));
    end;

    procedure GetPaymentArray(Rec: Record "Sales Invoice Header"): JsonArray
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

    procedure GetAlphabetPartOfString(InputString: Text[250]): Text[250]
    var
        i: Integer;
        Character: Char;
        AlphabetPart: Text[250];
    begin
        AlphabetPart := '';
        for i := 1 to StrLen(InputString) do begin
            Character := InputString[i];
            if (Character >= 'A') and (Character <= 'Z') then
                AlphabetPart := AlphabetPart + Character
            else
                if (Character >= 'a') and (Character <= 'z') then
                    AlphabetPart := AlphabetPart + Character;
        end;
        exit(AlphabetPart);
    end;

    procedure GetBuyerDetails(Rec: Record "Sales Invoice Header"): JsonObject
    var
        cust: Record Customer;
        JO: JsonObject;
        TextContent: Text[250];
    begin

        cust.Get(Rec."Bill-to Customer No.");
        JO.Add('buyerName', CopyStr(GetAlphabetPartOfString(cust.Name.ToLower()), 1, 30));
        // IF cust.City = '' then
        //     JO.Add('buyerAddress', 'Blank Address') else
        //     JO.Add('buyerAddress', GetAlphabetPartOfString(cust.City.ToLower()));
        // if (cust."Phone No." = '') or (StrLen(DELCHR(FORMAT(cust."Phone No."), '=', DELCHR(FORMAT(cust."Phone No."), '=', '1234567890'))) <> 10) then
        //     JO.Add('buyerPhone', '0722000000')
        // else
        //     JO.Add('buyerPhone', DELCHR(FORMAT(cust."Phone No."), '=', DELCHR(FORMAT(cust."Phone No."), '=', '1234567890')));


        if (cust."Telex Answer Back" <> '') AND (StrLen(cust."Telex Answer Back") = 11) then
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

    local procedure resolveControlUnitIP(Rec: Record "Sales Invoice Header"; what: Integer): Text
    var
        CUUsers: Record 51521061;
        Setup: Record 51521060;
        SINV: Record "Sales Invoice Header";
    begin

        CUUsers.Reset();
        CUUsers.SetRange(UserID, UserId);
        if NOT CUUsers.FindFirst() then
            Page.Run(Page::"Control Unit Users");

        if NOT CUUsers.FindFirst() then
            Error('No users have been confifured with he control units')
        else begin
            Setup.Get(CUUsers."Control Unit No");
            if (what = 1) then exit(Setup."IP Address") else exit(Setup."CU No.")
        end;
    end;

    procedure VerifyPIN(Rec: Record "Sales Invoice Header"): Text
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

    procedure GetLineItems(Rec: Record "Sales Invoice Header"): JsonArray
    var
        Lines: Record "Sales Invoice Line";
        Item: Record "Item";
        VATSetup: Record "VAT Posting Setup";
        JA: JsonArray;
        Items: JsonObject;
        UP: Decimal;
        hs: Text;
        counter: Integer;
        IntegerPart: Code[20];
        DecimalPart: Code[20];
        dec: Decimal;
    begin
        Lines.Reset;
        Lines.SETRANGE("Document No.", Rec."No.");
        Lines.SetFilter("Unit Price", '>%1', 0);
        ;
        // Lines.SetRange("Document Type", Rec."Document Type");
        Lines.SetFilter("No.", '<>%1', '');
        Lines.SetFilter(Quantity, '<>%1', 0);
        counter := 0;
        Amount := 0;
        if Lines.Find('-') then
            Repeat
                counter += 1;
                Items.Add('name', CopyStr(Lines.Description, 1, 42));
                // if (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Order]) then begin
                Items.Add('quantity', Lines.Quantity);
                UP := Round((Lines."Amount Including VAT" / Lines.Quantity), 0.000001);
                Amount += Round(Lines."Amount Including VAT", 0.0000001);

                Items.Add('unitPrice', UP);

                hs := resolveHSCode2(Lines.Description, Lines."VAT Identifier", Lines."No.");
                if hs <> '' then
                    Items.Add('hsCode', hs);
                if Lines.Description <> 'Currency Rounding' then
                    JA.Add(Items);
                Clear(Items);
            Until Lines.Next = 0;
        exit(JA);
    end;

    local procedure resolveHSCode(Rec: Record "Sales Invoice Line"): Code[20]
    var
        HSCodes: Record "HS Codes";
        HSCode: Code[20];
        ItemRec: Record Item;
    begin
        // HSCode := '';

        if (Rec.Description <> 'Currency Rounding') then begin
            HSCodes.Reset();
            if (Rec.Type = Rec.Type::Item) then
                HSCodes.SetRange("Item No.", Rec."No.")
            else begin
                ItemRec.Reset();
                ItemRec.SetRange(Description, Rec.Description);
                if ItemRec.FindFirst() then
                    HSCodes.SetRange("Item No.", ItemRec."No.");
            end;
            HSCodes.SetRange("VAT Identifier", Rec."VAT Identifier");
            if HSCodes.FindFirst() then
                exit(HSCodes.HSCode)
            else
                exit('');
        end;

    end;

    local procedure resolveHSCode2(Desc: Text[100]; VATID: code[10]; ItemNo: Code[10]): Code[20]
    var
        HSCodes: Record "HS Codes";
        HSCode: Code[20];
        ItemRec: Record Item;
    begin
        HSCode := '';

        if (Desc <> 'Currency Rounding') then begin
            HSCodes.Reset();
            HSCodes.SetRange("Item No.", ItemNo);
            HSCodes.SetRange("VAT Identifier", VATID);
            if HSCodes.FindFirst() then
                exit(HSCodes.HSCode)
            else begin
                //RMK
                IF CompanyName = 'RMK' then begin
                    case ItemNo of

                        '50004':
                            exit('0103.10.00');
                        '50005':
                            exit('0018.11.00');
                        '60100':
                            exit('3915.90.00');
                        '60200':
                            exit('3101.00.00');
                        '60350':
                            exit('0003.11.00');
                        '60360':
                            exit('0003.11.00');


                    end;
                end;

                ItemRec.Reset();
                ItemRec.SetRange(Description, Desc);
                if ItemRec.FindFirst() then begin
                    HSCodes.SetRange("Item No.", ItemRec."No.");
                    HSCodes.SetRange("VAT Identifier", VATID);
                    if HSCodes.FindFirst() then
                        exit(HSCodes.HSCode)
                    else
                        exit('');
                end;

            end;

        end;

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



