report 51520057 "Sales VAT ReturnsAL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Sales VAT ReturnsAL.rdlc';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("VAT Entry"; "VAT Entry")
        {
            DataItemTableView = SORTING("Document No.", "Posting Date") ORDER(Ascending) WHERE(Type = CONST(Sale), "Document Type" = FILTER(Invoice | "Credit Memo"), "Bill-to/Pay-to No." = FILTER(<> ''));
            PrintOnlyIfDetail = false;
            RequestFilterFields = "Posting Date", "Bill-to/Pay-to No.";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }

            column(CuInvoiceNo; CuInvoiceNo)
            {

            }

            column(CuNo; CuNo)
            {

            }

            column(SignTime; SignTime)
            {

            }
            column(USERID; UserId)
            {
            }
            column(VAT_Entry__GETFILTERS; "VAT Entry".GetFilters)
            {
            }
            column(vendorNo___; "Bill-to/Pay-to No.")
            {
            }
            column(VAT_Entry__Posting_Date_; "Posting Date")
            {
            }
            column(VAT_Entry__Document_No__; "Document No.")
            {
            }
            column(Base_Amount; Base + Amount)
            {
            }
            column(VAT_Entry_Amount; Amount)
            {
            }
            column(VendorRegNo; VendorRegNo)
            {
            }
            column(VendorName; VendorName)
            {
            }
            column(PurchaseHeader__Posting_Description_; PurchaseHeader."Posting Description")
            {
            }
            column(VAT_Entry_Base; Base)
            {
            }
            column(VAT_Entry__External_Document_No__; "External Document No.")
            {
            }
            column(VAT_Entry_Amount_Control7; Amount)
            {
            }
            column(Base_Amount_Control16; Base + Amount)
            {
            }
            column(VAT_Entry_Base_Control34; Base)
            {
            }
            column(Sales_VAT_ReportCaption; Sales_VAT_ReportCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Vendor_No_Caption; Vendor_No_CaptionLbl)
            {
            }
            column(Posting_DateCaption; Posting_DateCaptionLbl)
            {
            }
            column(Document_No_Caption; Document_No_CaptionLbl)
            {
            }
            column(Amount_With_VATCaption; Amount_With_VATCaptionLbl)
            {
            }
            column(V_A_T_Amount_Caption; V_A_T_Amount_CaptionLbl)
            {
            }
            column(VAT_Reg__No_Caption; VAT_Reg__No_CaptionLbl)
            {
            }
            column(Customer_NameCaption; Customer_NameCaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(Base_AmountCaption; Base_AmountCaptionLbl)
            {
            }
            column(VAT_Entry__External_Document_No__Caption; FieldCaption("External Document No."))
            {
            }
            column(TotalsCaption; TotalsCaptionLbl)
            {
            }
            column(VendorNo; VendorNo)
            {
            }
            column(Misclleaneous_V_A_TCaption; Misclleaneous_V_A_TCaptionLbl)
            {
            }
            column(VAT_Entry_Entry_No_; "Entry No.")
            {
            }
            column(pin; Vendors."Telex Answer Back")
            {
            }
            column(VAT_Entry_Type; Type)
            {
            }

            column(RelatedDocCU; RelatedDocCU)
            {

            }

            column(RelatedDocNo; RelatedDocNo)
            {

            }
            column(RelatedDocSignTime; RelatedDocSignTime)
            {

            }



            trigger OnAfterGetRecord()
            begin
                // IF "VAT Entry".Amount=0 THEN
                // CurrReport.SKIP;


                VendorName := '';
                VendorNo := '';

                if PurchaseHeader.Get("Document No.") then begin
                    VendorNo := PurchaseHeader."Sell-to Customer No.";
                    VendorName := PurchaseHeader."Sell-to Customer Name";
                    CuInvoiceNo := PurchaseHeader.CUInvoiceNo;
                    CuNo := PurchaseHeader.CUNo;
                    SignTime := COPYSTR(PurchaseHeader.SignTime, 1, 10);

                    // VendorInv:=PurchaseHeader."Vendor Invoice No.";
                    PurchaseHeader.CalcFields(PurchaseHeader."Amount Including VAT");

                    AmtwithVAT := PurchaseHeader."Amount Including VAT";
                    if Vendors.Get(PurchaseHeader."Sell-to Customer No.") then
                        VendorRegNo := Vendors."VAT Registration No.";
                end
                else begin
                    if CrmemoHeader.Get("Document No.") then
                        VendorNo := CrmemoHeader."Sell-to Customer No.";
                    VendorName := CrmemoHeader."Sell-to Customer Name";

                    If (SINV.GET(CrmemoHeader."Applies-to Doc. No.")) then begin
                        RelatedDocCU := SINV.CUNo;
                        RelatedDocNo := SINV.CUInvoiceNo;
                        RelatedDocSignTime := COPYSTR(SINV.SignTime, 1, 10);
                        ;
                    end;
                    // VendorInv:=CrmemoHeader."Vendor Cr. Memo No.";
                    CuInvoiceNo := CrmemoHeader.CUInvoiceNo;
                    CuNo := CrmemoHeader.CUNo;
                    SignTime := COPYSTR(CrmemoHeader.SignTime, 1, 10);

                    CrmemoHeader.CalcFields(CrmemoHeader."Amount Including VAT");
                    AmtwithVAT := -CrmemoHeader."Amount Including VAT";
                    if Vendors.Get(CrmemoHeader."Sell-to Customer No.") then
                        VendorRegNo := Vendors."VAT Registration No.";
                end;
            end;

            trigger OnPreDataItem()
            begin
                "VAT Entry".SetRange("VAT Entry".Type, "VAT Entry".Type::Sale);
            end;
        }
        dataitem("G/L Entry"; "G/L Entry")
        {
            DataItemTableView = SORTING("G/L Account No.", "Posting Date");
            PrintOnlyIfDetail = false;
            column(G_L_Entry__Posting_Date_; "Posting Date")
            {
            }
            column(G_L_Entry_Description; Description)
            {
            }
            column(Vendorno_; "VAT Entry"."Bill-to/Pay-to No.")
            {
            }
            column(G_L_Entry__Document_No__; "Document No.")
            {
            }
            column(G_L_Entry__External_Document_No__; "External Document No.")
            {
            }
            column(G_L_Entry_Amount; Amount)
            {
            }
            column(G_L_Entry_Amount_Control39; Amount)
            {
            }
            column(Misclleaneous_V_A_T_TotalCaption; Misclleaneous_V_A_T_TotalCaptionLbl)
            {
            }
            column(G_L_Entry_Entry_No_; "Entry No.")
            {
            }

            trigger OnPreDataItem()
            begin
                if VATGLFilter = '' then
                    Error('You must select the Misclleaneous VAT Account unde options')
                else
                    "G/L Entry".SetFilter("G/L Entry"."G/L Account No.", VATGLFilter);
                "G/L Entry".SetFilter("G/L Entry"."Posting Date", DateFilter);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(VATGLFilter; VATGLFilter)
                    {
                        Caption = 'Misc. VAT Account Filter';
                        TableRelation = "G/L Account";
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        DateFilter := "VAT Entry".GetFilter("VAT Entry"."Posting Date");
    end;

    var
        PurchaseHeader: Record "Sales Invoice Header";

        SINV: Record "Sales Invoice Header";
        CuNo: Text[50];
        RelatedDocNo: Text[50];

        RelatedDocCU: Text[50];

        RelatedDocSignTime: Text[100];
        CuInvoiceNo: Text[50];
        SignTime: Text[40];
        Vendors: Record Customer;
        VendorNo: Code[10];
        VendorName: Text[50];
        VendorRegNo: Code[20];
        VendorInv: Code[20];
        CrmemoHeader: Record "Sales Cr.Memo Header";
        AmtwithVAT: Decimal;
        VAT: Text[30];
        VATGLFilter: Text[130];
        DateFilter: Text[130];
        Sales_VAT_ReportCaptionLbl: Label 'Sales VAT Report';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Vendor_No_CaptionLbl: Label 'Vendor No.';
        Posting_DateCaptionLbl: Label 'Posting Date';
        Document_No_CaptionLbl: Label 'Document No.';
        Amount_With_VATCaptionLbl: Label 'Amount With VAT';
        V_A_T_Amount_CaptionLbl: Label 'V.A.T Amount ';
        VAT_Reg__No_CaptionLbl: Label 'VAT Reg. No.';
        Customer_NameCaptionLbl: Label 'Customer Name';
        DescriptionCaptionLbl: Label 'Description';
        Base_AmountCaptionLbl: Label 'Base Amount';
        TotalsCaptionLbl: Label 'Totals';
        Misclleaneous_V_A_TCaptionLbl: Label 'Misclleaneous V.A.T';
        Misclleaneous_V_A_T_TotalCaptionLbl: Label 'Misclleaneous V.A.T Total';
}

