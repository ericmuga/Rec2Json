table 51521064 "Imported SalesAL"
{

    fields
    {
        field(1; CustNO; Code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(2; Date; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; SPCode; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(4; ShiptoCOde; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(5; ExtDocNo; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(6; ItemNo; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Qty; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Location; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(9; SUOM; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(10; UnitPrice; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; ShiptoName; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(12; TotalHeaderAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; LineAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; TotalHeaderQty; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; LineNo; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(16; Type; Option)
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";

            trigger OnValidate()
            var
                TempSalesLine: Record "Sales Line" temporary;
            begin
            end;
        }
        field(17; Executed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(18; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(19; ItemBlockedStatus; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; RevertFlag; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(21; No; Code[20])
        {
            CalcFormula = Lookup("Sales Header"."No." WHERE("External Document No." = FIELD(ExtDocNo)));
            FieldClass = FlowField;
        }

        field(22; CUInvoiceNo; Code[100])
        {

        }

        field(23; CUNo; Code[100])
        {

        }
        field(24; SigningTime; Code[100])
        {

        }

        field(25; BillTo; Code[10])
        {

        }
    }

    keys
    {
        key(Key1; ExtDocNo, LineNo)
        {
        }
    }

    fieldgroups
    {
    }
}

