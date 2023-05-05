page 51520050 "Control Unit Setup"
{
    ApplicationArea = All;
    Caption = 'Control Unit Setup';
    PageType = List;
    SourceTable = 51521060;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("CU No."; "CU No.")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Control Unit Number';

                }

                field("IP Address"; "IP Address")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'IP Address';
                }

                field(Acitive; Acitive)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Is Active';
                }

                field(ImageServiceUri; ImageServiceUri)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Image Service URi';
                }

                field(QRCodeStorage; QRCodeStorage)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'QR Code Storage Location';
                }

                field("Friendly Name"; "Friendly Name")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Friendly Name';
                }

                field(PIN; PIN)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'PIN';
                }




            }
        }
    }
}
