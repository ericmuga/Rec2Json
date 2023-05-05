page 51520052 HSCodes
{
    ApplicationArea = All;
    Caption = 'HSCodes';
    PageType = List;
    SourceTable = 51521062;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; "Item No.")
                {

                }
                field(HSCode; HSCode)
                {

                }
                field("VAT Identifier"; "VAT Identifier")
                {

                }
            }
        }
    }
}
