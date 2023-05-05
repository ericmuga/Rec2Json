page 51520051 "Control Unit Users"
{
    ApplicationArea = All;
    Caption = 'Control Unit Users';
    PageType = List;
    SourceTable = 51521061;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(UserID; UserID)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'User ID';
                }

                field("Control Unit No"; "Control Unit No")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Control Unit No.';
                }

                field(Active; Active)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Active';
                }


            }
        }
    }
}
