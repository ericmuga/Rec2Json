page 51520054 "Sales Invoice List -PostAL"
{
    ApplicationArea = ALL;
    Caption = 'Post Level Orders';
    CardPageID = "Sales Invoice";
    DataCaptionFields = "Sell-to Customer No.";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Release,Posting,Invoice,Request Approval,Navigate';
    QueryCategory = 'Sales Invoice List';
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = CONST(Invoice),
                            "Transaction Specification" = FILTER(<> ''));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Genetal)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer.';
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Sell-to Post Code"; "Sell-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Country/Region Code"; "Sell-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Contact"; "Sell-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s main address.';
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s billing address.';
                    Visible = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';
                    Visible = false;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer at the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the address that the items are shipped to.';
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the posting of the sales document will be recorded.';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location from where inventory items to the customer on the sales document are to be shipped by default.';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the sales person who is assigned to the customer.';
                    Visible = false;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency of amounts on the sales document.';
                    Visible = false;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = false;
                }
                field("Campaign No."; "Campaign No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of the campaign that the document is linked to.';
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the document is open, waiting to be approved, has been invoiced for prepayment, or has been released to the next stage of processing.';
                    Visible = false;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    Visible = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the sales invoice must be paid.';
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment discount percentage granted if the customer pays on or before the date entered in the Pmt. Discount Date field.';
                    Visible = false;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                    Visible = false;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                    Visible = false;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                    Visible = false;
                }
                field("Package Tracking No."; "Package Tracking No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the shipping agent''s package number.';
                    Visible = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                    Visible = false;
                }
                field("Job Queue Status"; "Job Queue Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of a job queue entry or task that handles the posting of sales invoices.';
                    // Visible = JobQueueActive;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of amounts in the Line Amount field on the sales order lines. It is used to calculate the invoice discount of the sales order.';
                }
                field("Posting Description"; "Posting Description")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies additional posting information for the document. After you post the document, the description can add detail to vendor and customer ledger entries.';
                    Visible = false;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                }
                // field("Order Receiver"; "Order Receiver")
                // {
                // }
            }
        }

    }

    actions
    {



        area(processing)
        {


            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
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
                        CU: Codeunit 51520053;

                    begin
                        // CalcFields(QRCodeBlob);
                        if Rec.CUInvoiceNo = '' then begin
                            If (Signage.VerifyPIN(Rec) = '0100') then begin
                                Signage.SignInvoices(Rec);
                            end;
                        end;
                        Rec.SetRange("No.", "No.");
                        SIN := Rec."No.";
                        // //Post(CODEUNIT::"Sales-Post + Print");
                        // CODEUNIT::"Sales-Post (Yes/No)");

                        CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);

                        salesinv.RESET;
                        Setup.FindFirst();
                        salesinv.SETRANGE("Pre-Assigned No.", SIN);
                        if salesinv.FindFirst() then begin
                            // Message('found');
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
                    begin
                        // CalcFields(QRCodeBlob);
                        if Rec.CUInvoiceNo = '' then begin
                            If (Signage.VerifyPIN(Rec) = '0100') then begin
                                Signage.SignInvoices(Rec);
                            end;
                        end;
                        Rec.SetRange("No.", "No.");
                        SIN := Rec."No.";
                        // //Post(CODEUNIT::"Sales-Post + Print");
                        // CODEUNIT::"Sales-Post (Yes/No)");

                        CODEUNIT.Run(Codeunit::"Sales-Post (Yes/No)", Rec);

                        salesinv.RESET;
                        Setup.FindFirst();
                        salesinv.SETRANGE("Pre-Assigned No.", SIN);
                        if salesinv.FindFirst() then begin

                            CU.uploadAndShip(salesinv);
                            Report.Run(Report::"Standard Sales - Invoice", false, true, salesinv);

                            Report.Run(51520055, false, true, salesinv);

                        end;
                    end;
                }

            }
        }

    }

    trigger OnAfterGetCurrRecord()
    begin
        // SetControlAppearance;
        // CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);
    end;

    trigger OnOpenPage()
    var
    // SalesSetup: Record "311";
    begin
        SetSecurityFilterOnRespCenter;
        // JobQueueActive := SalesSetup.JobQueueActive;

        CopySellToCustomerFilter;
    end;




}

