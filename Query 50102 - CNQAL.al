query 50102 ICNQAL
{

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            DataItemTableFilter = "Document Type" = FILTER("Credit Memo");
            column(Document_No_; "Document No.")
            {
            }

            column(No_; "No.")
            {
            }

            column(Description; Description)
            {

            }

            column(VAT_Identifier; "VAT Identifier")
            {

            }
            column(Amount_Including_VAT; "Amount Including VAT")
            {
                Method = Sum;
                // Caption='sum_amt';
                // Name="sum_amt";
            }
        }
    }
}

