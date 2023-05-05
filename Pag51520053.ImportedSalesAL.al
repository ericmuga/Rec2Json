page 51520053 "Imported SalesAL"
{
    ApplicationArea = All;
    Caption = 'Imported SalesAL';
    PageType = List;
    SourceTable = "Imported SalesAL";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field(ExtDocNo; ExtDocNo)
                {

                }
                field(ItemNo; ItemNo)
                {

                }
                field(LineNo; LineNo) { }
                field(Location; Location) { }
                field(Date; Date) { }
                field(RevertFlag; RevertFlag) { }
                field(No; No) { }
                field(Qty; Qty) { }

                field(UnitPrice; UnitPrice) { }

                field(TotalHeaderAmount; TotalHeaderAmount) { }
                field(TotalHeaderQty; TotalHeaderQty) { }
                field(CustNO; CustNO) { }
                field(SPCode; SPCode)
                {

                }
                field(SUOM; SUOM) { }
                field(ShiptoCOde; ShiptoCOde) { }
                field(SigningTime; SigningTime) { }
                field(ShiptoName; ShiptoName) { }
                field(LineAmount; LineAmount) { }
                field(Executed; Executed) { }
                field(Posted; Posted) { }
                field(CUInvoiceNo; CUInvoiceNo) { }
                field(CUNo; CUNo) { }

            }
        }
    }
}
