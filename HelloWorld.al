pageextension 50100 SalesInvoiceExtension extends "Sales Invoice"
{

    actions
    {
        // Adding a new action group 'MyNewActionGroup' in the 'Creation' area
        addlast(Processing)
        {
            group(Posting)
            {
                action(Sign_Post)
                {
                    Caption = 'Sign Document';

                    trigger OnAction();
                    begin
                        Message(GetIpAddress());
                    end;
                }
            }
        }
    }

    procedure GetIPAddress(): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        J: JsonObject;
        ResponseText: Text;
        Headers: HttpHeaders;
        Request: HttpRequestMessage;
        Content: HttpContent;


    begin

//    Client.SetBaseAddress('https://api.ipify.org?format=json')
        
         if Client.Get('https://api.ipify.org?format=json', Response) then 
        begin
            if Response.IsSuccessStatusCode() then
             begin
                Response.Content().ReadAs(ResponseText);
                J.ReadFrom(ResponseText);
                exit(GetJsonTextField(J, 'ip'));
            end;
        end;

    end;

    procedure GetJsonTextField(O: JsonObject; Member: Text): Text
    var
        Result: JsonToken;
    begin
        if O.Get(Member, Result) then begin
            exit(Result.AsValue().AsText());
        end;
    end;

}
