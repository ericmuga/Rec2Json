table 51521061 "Control Unit Users"
{
    Caption = 'Control Unit Users';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; UserID; Code[250])
        {
            Caption = 'UserID';
            // TableRelation = User."User Name";
            DataClassification = ToBeClassified;
        }
        field(2; "Control Unit No"; Code[250])
        {
            Caption = 'Control Unit No';
            TableRelation = "Control Unit Setup"."CU No.";
            DataClassification = ToBeClassified;
        }
        field(3; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; UserID)
        {
            Clustered = true;
        }
    }
}
