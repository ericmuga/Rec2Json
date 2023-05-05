table 51521065 "Device Signage Log"
{
    Caption = 'Device Signage Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Device ID"; Code[250])
        {
            Caption = 'Device ID';
            DataClassification = ToBeClassified;
            TableRelation = "Control Unit Setup"."CU No.";
        }

        field(4; "Request DateTime"; DateTime)
        {
            Caption = 'Transaction DateTime';
            DataClassification = ToBeClassified;
        }

        field(3; "Response DateTime"; DateTime)
        {
            Caption = 'Transaction DateTime';
            DataClassification = ToBeClassified;
        }
        field(5; "Document Type"; Option)
        {
            OptionMembers = Invoice,CreditNote;
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
        }
        field(6; "User ID"; Code[250])
        {
            Caption = 'User ID';
            DataClassification = ToBeClassified;
        }
        field(7; Request; Text[2048])
        {
            Caption = 'Request';
            DataClassification = ToBeClassified;
        }

        field(12; RequestEnd; Text[2048])
        {
            Caption = 'RequestEnd';
            DataClassification = ToBeClassified;
        }

        field(13; RequestEndFinal; Text[2048])
        {
            Caption = 'RequestEndFinal';
            DataClassification = ToBeClassified;
        }
        field(8; Response; Text[2048])
        {
            Caption = 'Response';
            DataClassification = ToBeClassified;
        }
        field(9; "Document No."; Code[50])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(10; Error; Boolean)
        {
            Caption = 'Error';
            DataClassification = ToBeClassified;
        }

        field(11; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
