table 51521062 "HS Codes"
{
    Caption = 'HS Codes';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            // TableRelation = Item."No.";
            DataClassification = ToBeClassified;
        }
        field(2; HSCode; Code[20])
        {
            Caption = 'HSCode';
            DataClassification = ToBeClassified;
        }
        field(3; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Item No.", HSCode, "VAT Identifier")
        {
            Clustered = true;
        }
    }
}
