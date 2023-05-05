table 51521063 "Invoice Shipment Relation"
{
    Caption = 'Invoice Shipment Relation';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Shipment No."; Code[20])
        {
            Caption = 'Shipment No.';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Invoice No.")
        {
            Clustered = true;
        }
    }
}
