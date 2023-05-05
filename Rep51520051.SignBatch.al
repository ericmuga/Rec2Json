report 51520051 "Sign Batch"
{
    ProcessingOnly = true;
    Permissions = tabledata "Sales Invoice Header" = rmid;


    Caption = 'Sign Batch';
    dataset
    {

        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            RequestFilterFields = "No.";
            trigger OnAfterGetRecord()
            var
                CU: Codeunit "Control Unit SignageINV";
                Mailer: Codeunit "SMTP Mail";
                logs: Record "Device Signage Log";
                Original: text[250];
                Current: text[250];

            begin
                Original := SalesInvoiceHeader.CUInvoiceNo;
                SalesInvoiceHeader.CUInvoiceNo := '';
                SalesInvoiceHeader.SignTime := '';
                SalesInvoiceHeader.CUNo := '';
                SalesInvoiceHeader.Modify();

                if CU.VerifyPIN(SalesInvoiceHeader) = '0100' then
                    CU.SignInvoices(SalesInvoiceHeader);
                Current := SalesInvoiceHeader.CUInvoiceNo;

                // Mailer.CreateMessage('FCL System',
                //                         'bcsystem@farmerschoice.co.ke',
                //                         'emuga@farmerschoice.co.ke;irotich@farmerschoice.co.ke;pkiongo@farmeschoice.co.ke;jmathenge@farmerschoice.co.ke;ewandia@farmerschoice.co.ke',
                //                         'INVOICE RESIGNED :' + SalesInvoiceHeader."No.",
                //                         'Invoice ' + SalesInvoiceHeader."No." + ' was re-signed as the previous singing request was erronous. Original CUinvoiceNo. :' + Original + ' Current CUInvNo. :' + Current,
                //                         TRUE);
                // Mailer.Send();
                //logs.SetRange("Document No.",SalesInvoiceHeader."No.");
                Message('Action Completed Successfully');
            end;
        }
    }
    requestpage
    {


        layout
        {

            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
