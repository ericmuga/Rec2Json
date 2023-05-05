page 51520055 "Device Signage Logs"
{
    ApplicationArea = All;
    Caption = 'Device Signage Logs';
    PageType = List;
    SourceTable = "Device Signage Log";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.") { }
                field("Device ID"; "Device ID") { }
                field("Document Type"; "Document Type") { }
                field("Document No."; "Document No.") { }
                field("Request DateTime"; "Request DateTime") { }
                field("Response DateTime"; "Response DateTime") { }
                field("User ID"; "User ID") { }
                field(Request; Request) { }
                field(RequestEnd; RequestEnd) { }

                field(RequestEndFinal; RequestEndFinal) { }

                field(Response; Response) { }

            }
        }
    }
}
