codeunit 51520056 "Device Signage Logs"
{
    //this method will insert into the logs

    /*
        field("Entry No.";"Entry No."){}
                  field("Device ID";"Device ID"){}
                  field("Document Type";"Document Type"){}
                  field("Document No.";"Document No."){}
                  field("Transaction Date";"Transaction Date"){}
                  field("Transaction Time";"Transaction Time"){}
                  field("Transaction DateTime";"Transaction DateTime"){}
                  field(Request;Request){}
                  field(Response;Response){}  
    */

    procedure InsertLogs(dev: Text[250]; DocType: Option Invoice,CreditNote; DocNo: Code[50]; Req: Text; Res: Text; Err: Boolean; ReqDT: DateTime; ResDT: DateTime): Integer
    var
        logs: Record "Device Signage Log";
    begin
        logs.Init();
        logs."Device ID" := dev;
        logs."Document Type" := DocType;
        logs."Document No." := DocNo;

        logs.Request := CopyStr(Req, 1, 2048);
        // if StrLen(Req) > 2048 then
        //     logs.RequestEnd := CopyStr(Req, 2049, 4096);
        // if StrLen(Req) > 4096 then
        //     logs.RequestEndFinal := CopyStr(Req, 4097, 6144);

        logs.Response := CopyStr(Res, 1, 2048);
        logs.Error := Err;
        logs."Request DateTime" := ReqDT;
        logs."Response DateTime" := ResDT;
        logs."User ID" := UserId;
        logs.Insert(true);
        exit(logs."Entry No.");
    end;




}
