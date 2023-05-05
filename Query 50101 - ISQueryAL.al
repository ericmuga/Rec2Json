query 50101 ISQueryAL
{

    elements
    {
        dataitem(Imported_Sales; "Imported SalesAL")
        {
            DataItemTableFilter = Executed = FILTER(false);
            column(ExtDocNo; ExtDocNo)
            {
            }
            column(Sum_Qty; Qty)
            {
                Method = Sum;
            }
        }
    }
}

