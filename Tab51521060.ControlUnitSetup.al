table 51521060 "Control Unit Setup"
{
    Caption = 'Control Unit Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "CU No."; Code[250])
        {
            Caption = 'CU No.';
            DataClassification = ToBeClassified;
        }
        field(2; "IP Address"; Code[250])
        {
            Caption = 'IP Address';
            DataClassification = ToBeClassified;
        }
        field(3; Acitive; Boolean)
        {
            Caption = 'Acitive';
            InitValue = true;

            DataClassification = ToBeClassified;
        }
        field(4; "API "; Integer)
        {
            Caption = 'API ';
            DataClassification = ToBeClassified;
        }

        field(5; QRCodeStorage; Text[250])
        {
            Caption = 'QRCode Image Location';
        }

        field(6; ImageServiceUri; Text[250])
        {
            Caption = 'Image Service URi';
        }

        field(7; "Friendly Name"; Text[250])
        {
            Caption = 'Friendly Name';
        }

        

        field(8; PIN; Code[10])
        { }
    }
    keys
    {
        key(PK; "CU No.")
        {
            Clustered = true;
        }
    }
}
