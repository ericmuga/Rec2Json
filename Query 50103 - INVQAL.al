query 50103 INVQAL
{

    elements
    {
        dataitem(Sales_Invoice_Line; "Sales Invoice Line")
        {
            // DataItemTableFilter = "Document Type" = FILTER("Credit Memo");
            column(Document_No_; "Document No.")
            {
            }

            column(No_; "No.")
            {
            }

            column(Description; Description)
            {

            }
            column(Amount_Including_VAT; "Amount Including VAT")
            {
                Method = Sum;
            }
        }
    }
}

