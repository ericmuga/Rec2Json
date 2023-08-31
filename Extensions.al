

tableextension 51520050 QRCodeExtension extends "Sales Header"
{
    fields
    {
        field(50020; QRCode; Blob)
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50021; CUNo; Text[250])
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50022; CUInvoiceNo; Text[250])
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50023; SignedAt; DateTime)
        {
            Caption = 'Sign At';
            DataClassification = ToBeClassified;
        }

        field(50024; SignTime; Text[250])
        {
            Caption = 'Sign Time';
            DataClassification = ToBeClassified;
        }



    }
}


///extend sales invoice header
tableextension 51520051 QRCodeExtensionInv extends "Sales Invoice Header"
{
    fields
    {
        field(50020; QRCode; Blob)
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50021; CUNo; Text[250])
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50022; CUInvoiceNo; Text[250])
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50023; SignedAt; DateTime)
        {
            Caption = 'Sign At';
            DataClassification = ToBeClassified;
        }

        field(50024; SignTime; Text[250])
        {
            Caption = 'Sign Time';
            DataClassification = ToBeClassified;
        }
        field(50025; ShipmentNo; Text[20])
        {
            Caption = 'Shipment No.';
            DataClassification = ToBeClassified;
        }
    }
}/// 


tableextension 51520052 QRCodeExtensionCr extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50020; QRCode; Blob)
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50021; CUNo; Text[250])
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50022; CUInvoiceNo; Text[250])
        {
            Caption = 'QRCode';
            DataClassification = ToBeClassified;
        }

        field(50023; SignedAt; DateTime)
        {
            Caption = 'Sign At';
            DataClassification = ToBeClassified;
        }

        field(50024; SignTime; Text[250])
        {
            Caption = 'Sign Time';
            DataClassification = ToBeClassified;
        }
    }
}/// 


tableextension 51520053 Customer extends "Customer"
{
    fields
    {
        field(50034; ExemptionNo; Text[100])
        {
            Caption = 'Exemption Number';
            DataClassification = ToBeClassified;
        }

        // field(50100;CustStatGrp;Text[100])
        // {
        //     Caption='Customer Stats. Group';
        // }



    }




}

tableextension 51520054 Item extends "Item"
{



    fields
    {
        field(50034; HSCode; Text[100])
        {
            Caption = 'HS-Code';
            DataClassification = ToBeClassified;
            trigger OnValidate();
            var
                HSTable: Record "HS Codes";

            begin
                if HSCode <> '' then begin
                    if HSTable.Get("No.", HSCode, "VAT Prod. Posting Group") then begin
                        if HSTable.HSCode <> HSCode then begin
                            HSTable.HSCode := HSCode;
                            HSTable.Modify();
                        end;
                    end
                    else
                        HSTable.Insert(true);

                end;
            end;

        }


    }
}


tableextension 51520055 CustomerLedgerEntryCUInvNo extends "Cust. Ledger Entry"
{
    fields
    {

        field(50033; CUInvoiceNo; Text[250])
        {
            Caption = 'CUInvNo';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Invoice Header".CUInvoiceNo where("No." = field("Document No.")));

        }
    }
}

pageextension 51520064 ApplyCustEntriesCUInvNo extends "Apply Customer Entries"
{
    layout
    {

        addafter("Document No.")
        {
            field(CUInvoiceNo; CUInvoiceNo)
            {
                Caption = 'CU Invoice No.';
                Editable = false;
            }

        }

    }

}

pageextension 51520063 CustomerLedgerEntryCUInvNo extends "Customer Ledger Entries"
{
    layout
    {
        // Add changes to page layout here

        addafter("External Document No.")
        {
            field(CUInvoiceNo; CUInvoiceNo)
            {
                Caption = 'CU Invoice No.';
                Editable = false;
            }
        }

    }


}
pageextension 51520052 SalesInvoiceExtension extends "Sales Invoice"
{

    // Permissions = TableData "Sales Invoice Header" = rimd;

    layout
    {
        addafter("External Document No.")
        {
            field(CUInvoiceNo; CUInvoiceNo)
            {
                Caption = 'CU Invoice No.';
                Editable = false;
            }

            field(CUNo; CUNo)
            {
                Caption = 'Control Unit No.';
                Editable = false;
            }

            field(LPONo_; "Bill-to Address 2")
            {
                Caption = 'LPO No.';

            }
        }
    }

    actions
    {
        // Adding a new action group 'MyNewActionGroup' in the 'Creation' area
        addbefore("P&osting")
        {
            group(Posting)
            {
                action(Sign_Post)
                {
                    Caption = 'Sign & Post';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salesinv: Record "Sales Invoice Header";
                        salesinvoiceline: Record "Sales Invoice Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520051;
                        SH: Record "Sales Header";
                        CU: Codeunit UploadQRToInvoice;
                        CU2: Codeunit "Control Unit Signage";


                    begin
                        // CalcFields(QRCodeBlob);


                        if Rec.CUInvoiceNo = '' then begin
                            If (Signage.VerifyPIN(Rec) = '0100') then begin
                                Signage.SignInvoices(Rec);
                            end;
                        end;
                        SIN := Rec."No.";
                        // //Post(CODEUNIT::"Sales-Post + Print");
                        // CODEUNIT::"Sales-Post (Yes/No)");

                        CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);

                        salesinv.RESET;
                        Setup.FindFirst();
                        salesinv.SETRANGE("Pre-Assigned No.", SIN);
                        if salesinv.FindFirst() then begin
                            CU2.GenerateQRCode(Setup.ImageServiceUri, Rec.CUInvoiceNo);
                            CU.upload(salesinv);
                            Report.Run(Report::"Standard Sales - Invoice", false, true, salesinv);
                        end;
                    end;
                }

                action(Sign_Ship)
                {
                    Caption = 'Sign & Ship';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salesinv: Record "Sales Invoice Header";
                        salesinvoiceline: Record "Sales Invoice Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520051;
                        SH: Record "Sales Header";
                        NS: Record "No. Series Line";
                        SNRSetup: Record "Sales & Receivables Setup";
                        CU: Codeunit UploadQRToInvoice;
                        CU2: Codeunit "Control Unit Signage";

                    begin
                        // CalcFields(QRCodeBlob);
                        if Rec.CUInvoiceNo = '' then begin
                            If (Signage.VerifyPIN(Rec) = '0100') then begin
                                Signage.SignInvoices(Rec);
                            end;
                        end;

                        SIN := Rec."No.";
                        // //Post(CODEUNIT::"Sales-Post + Print");
                        // CODEUNIT::"Sales-Post (Yes/No)");

                        CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);

                        salesinv.RESET;
                        Setup.FindFirst();
                        salesinv.SETRANGE("Pre-Assigned No.", SIN);
                        if salesinv.FindFirst() then begin
                            CU2.GenerateQRCode(Setup.ImageServiceUri, Rec.CUInvoiceNo);
                            CU.uploadAndShip(salesinv);
                            Report.Run(Report::"Standard Sales - Invoice", false, true, salesinv);

                            Report.Run(51520055, false, true, salesinv);

                        end;
                    end;
                }
            }
        }
    }
}

pageextension 51520053 SalesCRMemoExtension extends "Sales Credit Memo"
{

    actions
    {
        // Adding a new action group 'MyNewActionGroup' in the 'Creation' area
        addbefore("P&osting")
        {
            group(Posting)
            {
                action(Sign_Post)
                {
                    Caption = 'Sign & Post';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;

                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salescrMemoHdr: Record "Sales Cr.Memo Header";
                        salescrMemoLine: Record "Sales Cr.Memo Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520051;
                        Sinv: Record "Sales Invoice Header";
                        CU: Codeunit UploadQRToCreditMemo;
                        CU2: Codeunit "Control Unit Signage";
                        CUINVNOINV: Code[250];
                    begin

                        Signage.CheckReturnReason(Rec);
                        SIN := Rec."No.";

                        if Rec."Applies-to Doc. No." = '' then Error('No invoice was applied');

                        if Sinv.GET(Rec."Applies-to Doc. No.") then
                            if Sinv.CUInvoiceNo = '' then begin
                                if Confirm(' The Applied invoice is not TIMS Signed, do you want to proceed with posting?') then begin
                                    CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);

                                    salescrMemoHdr.RESET;
                                    Setup.FindFirst();
                                    salescrMemoHdr.SETRANGE("Pre-Assigned No.", SIN);
                                    if salescrMemoHdr.FindFirst() then
                                        CU.upload(salescrMemoHdr);
                                    Report.Run(Report::"Standard Sales - Credit Memo2", false, true, salescrMemoHdr);

                                end;
                            end
                            else begin
                                if Sinv.GET(Rec."Applies-to Doc. No.") then
                                    if (Sinv.CUInvoiceNo = Rec.CUInvoiceNo) then begin
                                        Rec.CUInvoiceNo := '';
                                        Rec.CUNo := '';
                                        rec.SignTime := '';
                                        Rec.Modify();
                                        CurrPage.Update();
                                    end;

                                if (Rec.CUInvoiceNo = '') then
                                    If (Signage.VerifyPIN(Rec) = '0100') then
                                        Signage.SignInvoices(Rec)
                                    else
                                        Error('The system could not open the connection');

                                CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);
                                salescrMemoHdr.RESET;
                                Setup.FindFirst();
                                salescrMemoHdr.SETRANGE("Pre-Assigned No.", SIN);
                                if salescrMemoHdr.FindFirst() then begin
                                    CU2.GenerateQRCode(Setup.ImageServiceUri, Rec.CUInvoiceNo);
                                    CU.upload(salescrMemoHdr);
                                    Report.Run(Report::"Standard Sales - Credit Memo", false, true, salescrMemoHdr);
                                end;
                            end;


                    end;
                }

                action(Trim_Truncate)
                {
                    Caption = 'Trim & Truncate';

                    trigger OnAction()
                    var
                        lines: Record "Sales Line";

                    begin
                        //attempt to trim decimal places
                        lines.SetRange("Document No.", Rec."No.");
                        lines.SetRange("Document Type", Rec."Document Type");
                        lines.SetFilter(Quantity, '<>%1', 0);
                        lines.SetFilter("No.", '<>%1', '');
                        if lines.find('-') then
                            repeat
                                lines."Unit Price" := (lines."Unit Price" - 0.01);
                                lines.Modify();
                            until lines.Next() = 0;
                    end;

                }
            }
        }
    }





}


pageextension 51520062 SalesCRMemosExtension extends "Sales Credit Memos"
{

    actions
    {
        // Adding a new action group 'MyNewActionGroup' in the 'Creation' area
        addbefore("P&osting")
        {
            group(Posting)
            {
                action(Sign_Post)
                {
                    Caption = 'Sign & Post';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;

                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salescrMemoHdr: Record "Sales Cr.Memo Header";
                        salescrMemoLine: Record "Sales Cr.Memo Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520051;
                        Sinv: Record "Sales Invoice Header";
                        CU: Codeunit UploadQRToCreditMemo;
                        CU2: Codeunit "Control Unit Signage";
                        CUINVNOINV: Code[250];
                    begin
                        Rec.SetRange("No.", "No.");
                        Signage.CheckReturnReason(Rec);
                        SIN := Rec."No.";

                        if Rec."Applies-to Doc. No." = '' then Error('No invoice was applied');

                        if Sinv.GET(Rec."Applies-to Doc. No.") then
                            if Sinv.CUInvoiceNo = '' then begin
                                if Confirm(' The Applied invoice is not TIMS Signed, do you want to proceed with posting?') then begin
                                    CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);

                                    salescrMemoHdr.RESET;
                                    Setup.FindFirst();
                                    salescrMemoHdr.SETRANGE("Pre-Assigned No.", SIN);
                                    if salescrMemoHdr.FindFirst() then
                                        CU.upload(salescrMemoHdr);
                                    Report.Run(Report::"Standard Sales - Credit Memo2", false, true, salescrMemoHdr);

                                end;
                            end
                            else begin
                                if Sinv.GET(Rec."Applies-to Doc. No.") then
                                    if (Sinv.CUInvoiceNo = Rec.CUInvoiceNo) then begin
                                        Rec.CUInvoiceNo := '';
                                        Rec.CUNo := '';
                                        rec.SignTime := '';
                                        Rec.Modify();
                                        CurrPage.Update();
                                    end;

                                if (Rec.CUInvoiceNo = '') then
                                    If (Signage.VerifyPIN(Rec) = '0100') then
                                        Signage.SignInvoices(Rec)
                                    else
                                        Error('The system could not open the connection');

                                CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);
                                salescrMemoHdr.RESET;
                                Setup.FindFirst();
                                salescrMemoHdr.SETRANGE("Pre-Assigned No.", SIN);
                                if salescrMemoHdr.FindFirst() then begin
                                    CU2.GenerateQRCode(Setup.ImageServiceUri, Rec.CUInvoiceNo);
                                    CU.upload(salescrMemoHdr);
                                    Report.Run(Report::"Standard Sales - Credit Memo", false, true, salescrMemoHdr);
                                end;
                            end;


                    end;
                }


            }
        }
    }





}


pageextension 51520054 CustomerCard extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("VAT Bus. Posting Group")
        {
            field(ExemptionNo; ExemptionNo)
            {

            }
        }
    }

}




pageextension 51520055 PostedSalesInvoiceExtension extends "Posted Sales Invoice"
{

    //Permissions = TableData "Sales Shipment Buffer" = rimd;
    layout
    {
        addafter("External Document No.")
        {
            field(CUInvoiceNo; CUInvoiceNo)
            {
                Caption = 'CU Invoice No.';
                Editable = false;
            }

            field(CUNo; CUNo)
            {
                Caption = 'Control Unit No.';
                Editable = false;
            }
        }
    }


    actions
    {
        //add actions to sign a posted invoice
        addbefore("&Navigate")
        {
            group(Posting)
            {
                // action(Resign)
                // {
                //     trigger OnAction()
                //     begin
                //         Report.Run(51520051, true, true);
                //     end;


                // }
                action(Sign_Post)
                {
                    Caption = 'Sign';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salesinv: Record "Sales Invoice Header";
                        salesinvoiceline: Record "Sales Invoice Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520054;
                        SH: Record "Sales Header";
                        CU: Codeunit UploadQRToInvoice;

                    begin
                        // CalcFields(QRCodeBlob);

                        //check that sales person code
                        if Rec.CUInvoiceNo <> '' then Error('The Invoice has already been signed');
                        if Confirm('Are you sure you want to sign the posted invoice?') then begin
                            if Rec.CUInvoiceNo = '' then begin
                                If (Signage.VerifyPIN(Rec) = '0100') then
                                    Signage.SignInvoices(Rec)
                                else
                                    Error('The system was unable to initiate a signing request');
                                Rec.SetRange("No.", "No.");
                                // CU.upload(Rec);
                                Report.Run(Report::"Standard Sales - Invoice", false, true, Rec);
                                CurrPage.Update(true);
                            end;

                        end;

                    end;

                }

                action(Sign_Ship)
                {
                    Caption = 'Sign & Ship';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salesinv: Record "Sales Invoice Header";
                        salesinvoiceline: Record "Sales Invoice Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520054;
                        SH: Record "Sales Header";
                        NS: Record "No. Series Line";
                        SNRSetup: Record "Sales & Receivables Setup";
                        CU: Codeunit UploadQRToInvoice;
                    begin
                        if Rec.CUInvoiceNo <> '' then Error('The Invoice has already been signed');
                        if Confirm('Are you sure you want to sign the posted invoice?') then begin
                            if Rec.CUInvoiceNo = '' then begin
                                If (Signage.VerifyPIN(Rec) = '0100') then
                                    Signage.SignInvoices(Rec)
                                else
                                    Error('The system was unable to initiate a signing request');
                                Rec.SetRange("No.", "No.");
                                // CU.upload(Rec);
                                Report.Run(Report::"Standard Sales - Invoice", false, true, Rec);
                                Report.Run(51520055, false, true, Rec);
                                CurrPage.Update(true);
                            end;
                        end;

                    end;

                }
            }
        }

        // Adding a new action group 'MyNewActionGroup' in the 'Creation' area
        addbefore("&Navigate")
        {
            group(Process)
            {


                action(Ship)
                {
                    Caption = 'Print Shipment';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salesinv: Record "Sales Invoice Header";
                        salesinvoiceline: Record "Sales Invoice Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520051;
                        SH: Record "Sales Header";
                        NS: Record "No. Series Line";
                        SNRSetup: Record "Sales & Receivables Setup";
                    begin
                        SIN := Rec."No.";
                        salesinv.RESET;
                        Setup.FindFirst();
                        salesinv.SETRANGE("No.", SIN);
                        if salesinv.FindFirst() then begin
                            if salesinv.ShipmentNo = '' then begin
                                SNRSetup.FindFirst();
                                NS.LockTable();
                                NS.Reset();
                                NS.SetRange("Series Code", SNRSetup."Posted Shipment Nos.");
                                if NS.FindFirst() then begin
                                    salesinv.ShipmentNo := INCSTR(NS."Last No. Used");
                                    salesinv.Modify();
                                    NS."Last No. Used" := salesinv.ShipmentNo;
                                    NS.Modify();
                                end;


                            end;
                        end;
                        Report.Run(51520055, false, true, salesinv);
                    end;


                }

                action(Packing_List)
                {
                    Caption = 'Export Packing List';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = CreatePutawayPick;


                    trigger OnAction();


                    begin
                        Rec.SetRange("No.", "No.");
                        Report.Run(50085, true, true, Rec);

                    end;
                }
            }
        }
    }
}

pageextension 51520056 CustomerList extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
        addafter("VAT Bus. Posting Group")
        {
            field(ExemptionNo; ExemptionNo)
            {

            }
        }
    }

}

pageextension 51520057 ItemCard extends "Item Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("VAT Prod. Posting Group")
        {
            field(HSCode; HSCode)
            {

            }
        }
    }

}
pageextension 51520058 ItemList extends "Item List"
{
    layout
    {
        // Add changes to page layout here
        addafter("VAT Prod. Posting Group")
        {
            field(HSCode; HSCode)
            {

            }
        }
    }

}
pageextension 51520059 PostedCRMemoExtension extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("External Document No.")
        {
            field(CUInvoiceNo; CUInvoiceNo)
            {
                Caption = 'CU Cr. Note No.';
                Editable = false;

            }

            field(CUNo; CUNo)
            {
                Caption = 'Control Unit No.';
                Editable = false;
            }

        }

    }
    actions
    {
        addbefore("&Navigate")
        {
            group(Posting)
            {
                action(Print_Sign)
                {
                    Caption = 'Upload Signature';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        CU: Codeunit UploadQRToCreditMemo;
                        CU2: Codeunit "Control Unit Signage";
                        Setup: Record "Control Unit Setup";

                    begin

                        rec.SetRange("No.", "No.");

                        Setup.FindFirst();

                        CU2.GenerateQRCode(Setup.ImageServiceUri, Rec.CUInvoiceNo);

                        CU.upload(Rec);
                        Commit();
                        // rec.CalcFields(QRCode);
                        Report.Run(51520054, true, true, rec);
                    end;
                }

                action(Sign_Post)
                {
                    Caption = 'Sign';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;

                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salescrMemoHdr: Record "Sales Cr.Memo Header";
                        salescrMemoLine: Record "Sales Cr.Memo Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520055;
                        Sinv: Record "Sales Invoice Header";
                        CU: Codeunit UploadQRToCreditMemo;
                    begin
                        SIN := Rec."No.";

                        if Rec."Applies-to Doc. No." = '' then Error('No invoice was applied');
                        if Rec.CUInvoiceNo <> '' then Error('The document is already signed');
                        if Sinv.GET(Rec."Applies-to Doc. No.") then
                            if Sinv.CUInvoiceNo = '' then begin
                                Error(' The Applied invoice is not TIMS Signed');
                            end
                            else begin
                                If (Signage.VerifyPIN(Rec) = '0100') then
                                    Signage.SignInvoices(Rec)
                                else
                                    Error('The system could not open the connection');
                                // CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);
                                // salescrMemoHdr.RESET;
                                Setup.FindFirst();
                                // salescrMemoHdr.SETRANGE("Pre-Assigned No.", SIN);
                                Rec.SetRange("No.", "No.");
                                CU.upload(Rec);
                                Report.Run(Report::"Standard Sales - Credit Memo", false, true, Rec);

                            end;


                    end;
                }


            }
        }
    }

}


pageextension 51520060 PostedSalesINVExt extends "Posted Sales Invoices"
{

    layout
    {
        addafter("External Document No.")
        {
            field(CUInvoiceNo; CUInvoiceNo)
            {
                Caption = 'CU Invoice No.';
                Editable = false;

            }

            field(CUNo; CUNo)
            {
                Caption = 'Control Unit No.';
                Editable = false;
            }

            field(SignTime; SignTime)
            {
                Caption = 'Signed At';
                Editable = false;
            }

        }


    }

    actions
    {
        // Adding a new action group 'MyNewActionGroup' in the 'Creation' area
        addbefore(Navigate)
        {
            group(Posting)
            {

                action(Resign)
                {
                    trigger OnAction()
                    begin
                        Report.Run(51520051, true, true);
                    end;


                }
                action(Sign_Post)
                {
                    Caption = 'Sign & Post';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salesinv: Record "Sales Invoice Header";
                        salesinvoiceline: Record "Sales Invoice Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520054;
                        SH: Record "Sales Header";
                        CU: Codeunit UploadQRToInvoice;
                        lines: Record "Sales Line";

                    begin
                        // CalcFields(QRCodeBlob);

                        //check that sales person code

                        Rec.SetRange("No.", "No.");
                        if Rec.CUInvoiceNo <> '' then Error('The Invoice has already been signed');
                        if Confirm('Are you sure you want to sign the posted invoice?') then begin
                            if Rec.CUInvoiceNo = '' then begin
                                If (Signage.VerifyPIN(Rec) = '0100') then
                                    Signage.SignInvoices(Rec)
                                else
                                    Error('The system was unable to initiate a signing request');
                                Rec.SetRange("No.", "No.");
                                // CU.upload(Rec);
                                Report.Run(Report::"Standard Sales - Invoice", false, true, Rec);
                                CurrPage.Update(true);
                            end;

                        end;

                    end;

                }

                action(Sign_Ship)
                {
                    Caption = 'Sign & Ship';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salesinv: Record "Sales Invoice Header";
                        salesinvoiceline: Record "Sales Invoice Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520054;
                        SH: Record "Sales Header";
                        NS: Record "No. Series Line";
                        SNRSetup: Record "Sales & Receivables Setup";
                        CU: Codeunit UploadQRToInvoice;
                    begin
                        Rec.SetRange("No.", "No.");
                        if Rec.CUInvoiceNo <> '' then Error('The Invoice has already been signed');
                        if Confirm('Are you sure you want to sign the posted invoice?') then begin
                            if Rec.CUInvoiceNo = '' then begin
                                If (Signage.VerifyPIN(Rec) = '0100') then
                                    Signage.SignInvoices(Rec)
                                else
                                    Error('The system was unable to initiate a signing request');
                                Rec.SetRange("No.", "No.");
                                // CU.upload(Rec);
                                Report.Run(Report::"Standard Sales - Invoice", false, true, Rec);
                                Report.Run(51520055, false, true, Rec);
                                CurrPage.Update(true);
                            end;
                        end;

                    end;

                }
            }

            group(Shipment)
            {
                action(PrintShipment)
                {
                    Caption = 'Print Shipment';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = Shipment;

                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salescrMemoHdr: Record "Sales Cr.Memo Header";
                        salescrMemoLine: Record "Sales Cr.Memo Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520051;
                        CU: Codeunit UploadQRToInvoice;
                        NS: Record "No. Series Line";
                        SNRSetup: Record "Sales & Receivables Setup";
                    begin
                        begin
                            Rec.SetFilter("No.", "No.");
                            if Rec.FindFirst() then
                                CU.printShipment(Rec);

                            Report.Run(51520055, false, true, Rec);
                            Rec.Reset();
                        end;
                    end;
                }
            }
        }


    }
}
pageextension 51520061 PostedSalesCRMemos extends "Posted Sales Credit Memos"
{
    layout
    {
        addafter("Posting Date")
        {
            field(CUInvoiceNo; CUInvoiceNo)
            {
                Caption = 'CU Cr. Note No.';
                Editable = false;

            }

            field(CUNo; CUNo)
            {
                Caption = 'Control Unit No.';
                Editable = false;
            }

            field(SignTime; SignTime)
            {
                Caption = 'Signed At';
                Editable = false;
            }

        }


    }

    actions
    {
        addbefore("&Navigate")
        {
            group(Posting)
            {
                action(Print_Sign)
                {
                    Caption = 'Upload Signature';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;


                    trigger OnAction();
                    var
                        CU: Codeunit UploadQRToCreditMemo;
                        CU2: Codeunit "Control Unit Signage";
                        Setup: Record "Control Unit Setup";

                    begin

                        rec.SetRange("No.", "No.");

                        Setup.FindFirst();

                        CU2.GenerateQRCode(Setup.ImageServiceUri, Rec.CUInvoiceNo);

                        CU.upload(Rec);
                        Commit();
                        // rec.CalcFields(QRCode);
                        Report.Run(51520054, true, true, rec);
                    end;
                }

                action(Sign_Post)
                {
                    Caption = 'Sign';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = PostDocument;

                    trigger OnAction();
                    var
                        OutS: OutStream;
                        TextVar: Text;
                        salescrMemoHdr: Record "Sales Cr.Memo Header";
                        salescrMemoLine: Record "Sales Cr.Memo Line";
                        QR: Text;
                        Setup: Record 51521060;
                        SIN: Code[20];
                        Signage: Codeunit 51520055;
                        Sinv: Record "Sales Invoice Header";
                        CU: Codeunit UploadQRToCreditMemo;
                    begin
                        Rec.SetRange("No.", "No.");
                        SIN := Rec."No.";

                        if Rec."Applies-to Doc. No." = '' then Error('No invoice was applied');
                        if Rec.CUInvoiceNo <> '' then Error('The document is already signed');
                        if Sinv.GET(Rec."Applies-to Doc. No.") then
                            if Sinv.CUInvoiceNo = '' then begin
                                Error(' The Applied invoice is not TIMS Signed.');
                            end
                            else begin
                                if Sinv.GET(Rec."Applies-to Doc. No.") then
                                    if (Sinv.CUInvoiceNo = Rec.CUInvoiceNo) then begin
                                        Rec.CUInvoiceNo := '';
                                        Rec.CUNo := '';
                                        rec.SignTime := '';
                                        Rec.Modify();
                                        CurrPage.Update();
                                    end;
                                If (Signage.VerifyPIN(Rec) = '0100') then
                                    Signage.SignInvoices(Rec)
                                else
                                    Error('The system could not open the connection');
                                // CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);
                                // salescrMemoHdr.RESET;
                                Setup.FindFirst();
                                // salescrMemoHdr.SETRANGE("Pre-Assigned No.", SIN);
                                Rec.SetRange("No.", "No.");
                                CU.upload(Rec);
                                Report.Run(Report::"Standard Sales - Credit Memo", false, true, Rec);

                            end;


                    end;
                }

                action(Print_Doc)
                {
                    Caption = 'Print';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = Print;
                    trigger OnAction()
                    var
                        CU: Codeunit UploadQRToCreditMemo;
                        CU2: Codeunit "Control Unit Signage";
                        Setup: Record "Control Unit Setup";

                    begin
                        rec.SetRange("No.", "No.");


                        if Rec.CUInvoiceNo <> '' then begin
                            CU2.GenerateQRCode(Setup.ImageServiceUri, Rec.CUInvoiceNo);
                            CU.upload(Rec);
                            Commit();
                            Setup.FindFirst();
                        end;

                        // rec.CalcFields(QRCode);
                        Report.Run(51520054, true, true, rec)
                    end;

                }



            }
        }
    }
}


