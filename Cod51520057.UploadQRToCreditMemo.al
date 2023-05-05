codeunit 51520057 UploadQRToCreditMemo
{

    Permissions = tabledata "Sales Cr.Memo Header" = rmid;

    TableNo = "Sales Cr.Memo Header";


    trigger OnRun()
    begin



    end;


    procedure upload(SN: Record "Sales Cr.Memo Header")
    var
        QR: Text[250];
        Setup: Record 51521060;
    begin
        Setup.FindFirst();
        QR := SN.CUInvoiceNo + '.png';
        SN.QRCode.Import(Setup.QRCodeStorage + QR);
        SN.Modify();
    end;




}
