codeunit 51520052 "Import SalesAL"
{
    // Get from imported sales,
    // Create Header
    // Create Lines
    // emuga@farmerschoice.co.ke;gwaweru@farmerschoice.co.ke;vmuniu@farmerschoice.co.ke;dmbugua@farmerschoice.co.ke;ekaranja@farmerschoice.co.ke


    trigger OnRun()
    begin
        //ISQ.SETRANGE(ExtDocNo,'SI+N000024386');
        ISQ.OPEN;
        while ISQ.READ do begin
            //ISRun.LOCKTABLE;
            ISRun.Reset;
            ISRun.SetRange(ExtDocNo, ISQ.ExtDocNo);
            if ISRun.FindFirst then
                if CreteHeader(ISRun) <> '' then begin
                    IS.Reset;
                    IS.SetRange(ExtDocNo, ISQ.ExtDocNo);
                    if IS.Find('-') then
                        repeat
                            CreateLine(IS);
                        until IS.Next = 0;

                    SH.Reset;
                    SH.SetRange("Document Type", SH."Document Type"::Invoice);
                    SH.SetRange("External Document No.", ISQ.ExtDocNo);
                    SH.SetAutoCalcFields("Amount Including VAT");
                    if SH.FindFirst then
                        if Abs(Abs(SH."Amount Including VAT") - Abs(ISRun.TotalHeaderAmount)) < 1 then begin
                            SINVH.Reset;
                            SINVH.SetRange("External Document No.", ISQ.ExtDocNo);
                            if not SINVH.FindFirst then begin
                                CODEUNIT.Run(80, SH);
                                IS.Reset;
                                IS.SetRange(ExtDocNo, ISQ.ExtDocNo);
                                IS.DeleteAll;
                            end
                            else //meanining a posted invoice was found
                               begin
                                SL2.Reset;
                                SL2.SetRange("Document Type", SL2."Document Type"::Invoice);
                                SL2.SetRange("Document No.", SH."No.");
                                if SL2.FindSet then
                                    SL2.DeleteAll(false);

                                SH.Delete(false);

                                IS.Reset;
                                IS.SetRange(ExtDocNo, ISQ.ExtDocNo);
                                if IS.FindSet then
                                    IS.DeleteAll;
                            end;
                        end
                        else begin
                            SH.Reset;
                            SH.SetRange("Document Type", SH."Document Type"::Invoice);
                            SH.SetRange("External Document No.", ISQ.ExtDocNo);
                            SH.SetAutoCalcFields("Amount Including VAT");
                            if SH.FindFirst then begin

                                Mess := 'Invoice Number: ' + ISRun.ExtDocNo
                                                           + ' to Customer:' + SH."Sell-to Customer Name"
                                                           + '\ On:' + Format(SH."Posting Date")
                                                          + ' imported with a value difference and wasnt posted. Sales Server Value:'
                                                          + Format(ISRun.TotalHeaderAmount)
                                                          + '; Main Server Value:'
                                                          + Format(SH."Amount Including VAT");
                                SMTPMAIL.CreateMessage('System',
                                                       'BCSystem@farmerschoice.co.ke',
                                                       'emuga@farmerschoice.co.ke;gwaweru@farmerschoice.co.ke;vmuniu@farmerschoice.co.ke;dmbugua@farmerschoice.co.ke;ekaranja@farmerschoice.co.ke',
                                                        ISRun.ExtDocNo + ': Imbalance',
                                                         Mess,
                                                    true);
                                SMTPMAIL.Send;
                                Clear(SMTPMAIL);
                            end;
                        end;
                end;
        end;
        ISQ.CLOSE;
        Clear(ISQ);
        Clear(Mess);
    end;

    var
        SH: Record "Sales Header";
        SL: Record "Sales Line";
        ST: Record "Ship-to Address";
        Item: Record Item;
        Cust: Record Customer;
        IS: Record "Imported SalesAL";
        SINVH: Record "Sales Invoice Header";
        ShipTo: Record "Ship-to Address";
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Record "No. Series Line";
        IS2: Record "Imported SalesAL";
        ValidateTotal: Decimal;
        PostingGrp: Record "Customer Posting Group";
        Salesperson: Record "Salesperson/Purchaser";
        ValidateQtyTotal: Decimal;
        ISRun: Record "Imported SalesAL";
        Window: Dialog;
        inventorypostingSetup: Record "Inventory Posting Setup";
        Invpostset: Record "Inventory Posting Setup";
        CustBlockedStatus: Option " ",Ship,Invoice,All;
        ItemBlockedStatus: Boolean;
        CustBlockedStatus2: Option " ",Ship,Invoice,All;
        SL2: Record "Sales Line";
        ILE: Record "Item Ledger Entry";
        VQty: Decimal;
        VTT: Decimal;
        Flag: Integer;
        GrandQty: Decimal;
        GrandTT: Decimal;
        GL: Record "G/L Entry";
        SMTPMAIL: Codeunit "SMTP Mail";
        Mess: Text[250];
        ISQ: Query 50101;

    local procedure CreteHeader(IS: Record "Imported SalesAL") InvoiceNo: Code[20]
    var
        SH: Record "Sales Header";
        IS2: Record "Imported SalesAL";
        SINVH: Record "Sales Invoice Header";
    begin
        with IS do begin
            SH.Reset;
            SH.SetRange("Document Type", SH."Document Type"::Invoice);
            SH.SetRange("External Document No.", IS.ExtDocNo);
            if not SH.FindFirst then begin
                SINVH.Reset;
                SINVH.SetRange("External Document No.", IS.ExtDocNo);
                if not SINVH.FindFirst then begin
                    if ResolveBlockedOrMissingCustomer(CustNO, ExtDocNo) then begin
                        SH.Init;
                        SH."Document Type" := SH."Document Type"::Invoice;
                        SH."No." := '';
                        SH.Validate("Sell-to Customer No.", CustNO);
                        SH."Posting Date" := Date;
                        SH."Shipment Date" := Date;
                        SH."Due Date" := Date;
                        SH."Document Date" := Date;
                        SH.Validate("External Document No.", ExtDocNo);
                        SH."Assigned User ID" := format(USERID);
                        InsertAndValidateShipTo(SH, ShiptoCOde, ShiptoName);
                        SH."Salesperson Code" := IS.SPCode;
                        SH.CUInvoiceNo := IS.CUInvoiceNo;
                        SH.CUNo := IS.CUNo;
                        SH.SignTime := IS.SigningTime;
                        if IS.BillTo <> '' then
                            SH."Bill-to Customer No." := IS.BillTo;

                        //
                        // ValidateBillTo(SH);

                        // if Cust.Get(SH."Sell-to Customer No.") then begin
                        //     Cust.TestField("Customer Posting Group");
                        //     if PostingGrp.Get(Cust."Customer Posting Group") then begin
                        //         if PostingGrp.Code = 'CASH SALES' then begin
                        //             if Salesperson.Get(IS.SPCode) then begin
                        //                 //If SalesPerson Customer No. is Not Blank
                        //                 if Salesperson.CustNo <> '' then
                        //                     SH."Bill-to Customer No." := Salesperson.CustNo
                        //                 else begin
                        //                     //If SalesPerson Customer No. is Blank
                        //                     if Cust."Bill-to Customer No." <> '' then
                        //                         //Insert Customer's Bill To No.
                        //                         SH."Bill-to Customer No." := Cust."Bill-to Customer No."
                        //                     else begin
                        //                         //If Customer Bill To is Blank & SalesPerson is Not Blank
                        //                         if Cust."Salesperson Code" <> '' then begin
                        //                             if Salesperson.Get(Cust."Salesperson Code") then
                        //                                 if Salesperson.CustNo <> '' then
                        //                                     SH."Bill-to Customer No." := Salesperson.CustNo;
                        //                         end else begin
                        //                             //If Customer's Bill To & SalesPerson is Blank
                        //                             SH."Bill-to Customer No." := Cust."No.";
                        //                             SH."Salesperson Code" := IS.SPCode;
                        //                         end;
                        //                     end;
                        //                 end;
                        //                 // SH.VALIDATE("Bill-to Customer No.");

                        //             end;
                        //         end;
                        //     end;
                        // end;

                        if SH."Salesperson Code" = '' then SH."Salesperson Code" := SPCode;


                        // SH."Customer Disc. Group" := Cust."District Group Code";
                        SH.Insert(true);
                        exit(SH."No.");
                    end
                    else
                        exit('');
                end
                else //Meaning Posted Invoice was found;
                  begin
                    IS2.Reset;
                    IS2.SetRange(ExtDocNo, ExtDocNo);
                    IS2.ModifyAll(Executed, true);
                    exit('');
                end;
            end
            else
                exit(SH."No.");
        end;//End Create Header;


    end;

    local procedure FixInvPostingSetup(ISLine: Record "Imported SalesAL") ISOpen: Boolean
    var
        InvPSet: Record "Inventory Posting Setup";
        InvPSet2: Record "Inventory Posting Setup";
        Item2: Record Item;
        SMTPMAIL: Codeunit "SMTP Mail";
        Mess: Text[250];
    begin
        if not Item2.Get(ISLine.ItemNo) or Item2.Blocked then begin
            Mess := 'Item ' + ISLine.ItemNo + ' is blocked, Invoice No:' + ISLine.ExtDocNo + ' Failed to import correctly';

            SMTPMAIL.CreateMessage('System',
                                   'BCSystem@farmerschoice.co.ke',
                                   'emuga@farmerschoice.co.ke;gwaweru@farmerschoice.co.ke;vmuniu@farmerschoice.co.ke;dmbugua@farmerschoice.co.ke;ekaranja@farmerschoice.co.ke',
                                    'Item ' + ISLine.ItemNo + ' is blocked',
                                     Mess,
                                true);
            SMTPMAIL.Send;
            Clear(SMTPMAIL);
            exit(false);
        end;

        InvPSet.SetRange("Invt. Posting Group Code", Item2."Inventory Posting Group");
        InvPSet.SetRange("Location Code", ISLine.Location);
        if not InvPSet.FindFirst then begin
            InvPSet2.SetRange("Invt. Posting Group Code", Item2."Inventory Posting Group");
            InvPSet2.SetRange("Location Code", '3535');
            if InvPSet2.FindFirst then begin
                Invpostset.Init;
                Invpostset."Invt. Posting Group Code" := Item2."Inventory Posting Group";
                Invpostset."Location Code" := ISLine.Location;
                Invpostset."Inventory Account" := InvPSet2."Inventory Account";
                Invpostset."Material Variance Account" := '';
                Invpostset."Inventory Account (Interim)" := InvPSet2."Inventory Account (Interim)";
                Invpostset."Cap. Overhead Variance Account" := '';
                Invpostset."Capacity Variance Account" := '';
                Invpostset.Description := InvPSet2.Description;
                Invpostset."Mfg. Overhead Variance Account" := '';
                Invpostset."Subcontracted Variance Account" := '';
                Invpostset."WIP Account" := '';
                Invpostset."View All Accounts on Lookup" := true;
                Invpostset.Insert;
            end;
        end;
        exit(true);
    end;

    // procedure ValidateBillTo(SH: Record "Sales Header")
    // var
    //     Cust: Record Customer;
    //     PostingGrp: Record "Customer Posting Group";
    //     Salesperson: Record "Salesperson/Purchaser";
    // begin
    //     //update billto
    //     if Cust.Get(SH."Sell-to Customer No.") then begin
    //         Cust.TestField("Customer Posting Group");
    //         if PostingGrp.Get(Cust."Customer Posting Group") then begin
    //             if PostingGrp.Code = 'CASH SALES' then begin
    //                 if Salesperson.Get(IS.SPCode) then begin
    //                     //If SalesPerson Customer No. is Not Blank
    //                     if Salesperson.CustNo <> '' then
    //                         SH."Bill-to Customer No." := Salesperson.CustNo
    //                     else begin
    //                         //If SalesPerson Customer No. is Blank
    //                         if Cust."Bill-to Customer No." <> '' then
    //                             //Insert Customer's Bill To No.
    //                             SH."Bill-to Customer No." := Cust."Bill-to Customer No."
    //                         else begin
    //                             //If Customer Bill To is Blank & SalesPerson is Not Blank
    //                             if Cust."Salesperson Code" <> '' then begin
    //                                 if Salesperson.Get(Cust."Salesperson Code") then
    //                                     if Salesperson.CustNo <> '' then
    //                                         SH."Bill-to Customer No." := Salesperson.CustNo;
    //                             end else begin
    //                                 //If Customer's Bill To & SalesPerson is Blank
    //                                 SH."Bill-to Customer No." := Cust."No.";
    //                                 SH."Salesperson Code" := IS.SPCode;
    //                             end;
    //                         end;
    //                     end;
    //                     // SH.VALIDATE("Bill-to Customer No.");

    //                 end;
    //             end;
    //         end;
    //     end;
    // end;

    procedure InsertAndValidateShipTo(SH: Record "Sales Header"; ShiptoCOde: Code[10]; ShiptoName: Text)
    var
        ShipTo: Record "Ship-to Address";
    begin
        if ShiptoCOde <> '' then begin
            ShipTo.Reset;
            ShipTo.SetFilter(Code, ShiptoCOde);
            ShipTo.SetFilter("Customer No.", SH."Sell-to Customer No.");
            if ShipTo.FindFirst then
                SH.Validate("Ship-to Code", ShipTo.Code)
            else //insert Ship-to if not exists
                  begin
                ShipTo.Init;
                ShipTo.Validate(Code, ShiptoCOde);
                ShipTo.Validate("Customer No.", SH."Sell-to Customer No.");
                ShipTo.Validate(Name, ShiptoName);
                ShipTo.Insert(true);
                SH."Ship-to Code" := ShiptoCOde;
                SH."Ship-to Name" := ShiptoName;
            end;
        end;
    end;

    local procedure ResolveBlockedOrMissingCustomer(CustNo: Code[10]; InvoiceNo: Code[20]) Found: Boolean
    var
        Cust: Record Customer;
        SMTPMAIL: Codeunit "SMTP Mail";
        Mess: Text[250];
    begin
        if not Cust.Get(CustNo) then begin
            Mess := 'Customer:' + Cust."No." + 'was not found, this prevented Invoice' + InvoiceNo + ' from being imported';
            CustBlockedStatus := Cust.Blocked;
            SMTPMAIL.CreateMessage('System',
                                    'BCSystem@farmerschoice.co.ke',
                                    'emuga@farmerschoice.co.ke;gwaweru@farmerschoice.co.ke;vmuniu@farmerschoice.co.ke;dmbugua@farmerschoice.co.ke;ekaranja@farmerschoice.co.ke',
                                     'Customer ' + CustNo + ' not found.',
                                      Mess,
                                      true);
            SMTPMAIL.Send;
            Clear(SMTPMAIL);
            exit(false);
        end
        else begin
            if Cust.Blocked <> Cust.Blocked::" " then begin
                Mess := 'Customer:' + Cust."No." + 'is Blocked status prevented Invoice' + InvoiceNo + ' from being imported.';
                CustBlockedStatus := Cust.Blocked;
                SMTPMAIL.CreateMessage('System',
                                        'BCSystem@farmerschoice.co.ke',
                                        'emuga@farmerschoice.co.ke;gwaweru@farmerschoice.co.ke;vmuniu@farmerschoice.co.ke;dmbugua@farmerschoice.co.ke;ekaranja@farmerschoice.co.ke',
                                        'Customer ' + CustNo + ' is Blocked.',
                                        Mess,
                                        true);
                SMTPMAIL.Send;
                Clear(SMTPMAIL);
                exit(false);
            end
            else
                exit(true);
        end;
    end;

    local procedure CreateLine(IS: Record "Imported SalesAL")
    var
        SH: Record "Sales Header";
        SL: Record "Sales Line";
    // CSG: Record 50105;
    begin
        SH.Reset;
        SH.SetRange("Document Type", SH."Document Type"::Invoice);
        SH.SetRange("External Document No.", IS.ExtDocNo);
        if SH.FindFirst then
            with SH do begin
                Cust.Get("Sell-to Customer No.");
                if not SL.Get("Document Type", "No.", IS.LineNo) then begin
                    SL.Init;
                    if FixInvPostingSetup(IS) then begin
                        SL.Validate("Document Type", "Document Type");
                        SL."Line No." := IS.LineNo;
                        SL.Validate("Document No.", "No.");
                        SL."Shipment Date" := "Posting Date";
                        SL."Posting Date" := "Posting Date";
                        SL.Validate(Type, SL.Type::Item);
                        SL.Validate("No.", IS.ItemNo);
                        SL.Validate(Quantity, IS.Qty);
                        SL.Validate("Sell-to Customer No.", "Sell-to Customer No.");
                        SL.Validate("Location Code", IS.Location);
                        if SL."Location Code" = '' then SL."Location Code" := '3535';

                        if SL."No." in ['H221165', 'H221154'] then
                            if SL."No." in ['', '5005'] then
                                SL."Location Code" := '3535';



                        SL.Insert(true);
                        IS.Executed := true;
                        IS.Modify;
                    end;
                end;
            end;



    end;

    // procedure ValidateLocationCode(SH: Record "Sales Header"; SalesL: Record "Sales Line")
    // var
    //     SL: Record "Sales Line";
    //     Item: Record Item;
    //     Salesperson: Record "Salesperson/Purchaser";
    // begin
    //     Salesperson.Get(SH."Salesperson Code");
    //     if not (SH."Sell-to Customer No." in ['96279', '99073', '93175', '94600', '94797', '99850', '90031']) then begin
    //         if SalesL."No." in ['H221165', 'H221154'] then begin
    //             if Salesperson.DefaultLocation <> '' then
    //                 SalesL."Location Code" := Salesperson.DefaultLocation
    //             else
    //                 SalesL."Location Code" := '3535';
    //         end
    //         else begin
    //             if Salesperson.DefaultLocation <> '' then
    //                 SalesL."Location Code" := Salesperson.DefaultLocation
    //             else
    //                 SalesL."Location Code" := '3535';

    //             if (StrPos(Item."No.",'J')=1)or (StrPos(Item."No.",'BJ')=1) and (SalesL."Location Code"='')   then
    //             begin
    //               if CompanyName='FCL' then  SalesL.Validate("Location Code",'3535') else SalesL.Validate("Location Code",'B3535');
    //             end
    //              else
    //                if SalesL."Location Code"='' then
    //                 if CompanyName='FCL' then  SalesL.Validate("Location Code",'3998') else SalesL.Validate("Location Code",'B3535');
    //                SalesL."Location Code" := '3535';
    //                if Salesperson."Code" in ['270','B270'] then 
    //                 case CompanyName of
    //                   'FCL':SalesL."Location Code":='3600';
    //                   'CM':SalesL."Location Code":='B3600';
    //                 end;

    //         end;
    //     end;
    // end;
}

