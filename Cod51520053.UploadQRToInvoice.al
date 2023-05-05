codeunit 51520053 UploadQRToInvoice
{
    Permissions = tabledata "Sales Invoice Header" = rmid;

    TableNo = "Sales Invoice Header";


    trigger OnRun()
    begin



    end;


    procedure upload(SN: Record "Sales Invoice Header")
    var
        QR: Text[250];
        Setup: Record 51521060;
    begin
        Setup.FindFirst();
        QR := SN.CUInvoiceNo + '.png';
        SN.QRCode.Import(Setup.QRCodeStorage + QR);
        SN.Modify();
    end;

    procedure registerSignature(SN: Record "Sales Invoice Header"; CUNo: Text[250]; CUInvNo: Text[250]; STime: Text[250])
    var
        QR: Text[250];
        Setup: Record 51521060;
    begin
        Setup.FindFirst();
        QR := SN.CUInvoiceNo + '.png';
        SN.QRCode.Import(Setup.QRCodeStorage + QR);
        SN.Modify();
    end;

    procedure uploadCR(SN: Record "Sales Cr.Memo Header")
    var
        QR: Text[250];
        Setup: Record 51521060;
    begin



        Setup.FindFirst();
        QR := SN.CUInvoiceNo + '.png';
        SN.QRCode.Import(Setup.QRCodeStorage + QR);


        SN.Modify();
    end;

    procedure uploadAndShip(SN: Record "Sales Invoice Header")
    var
        QR: Text[250];
        Setup: Record 51521060;
        NS: Record "No. Series Line";
        SNRSetup: Record "Sales & Receivables Setup";
    begin
        Setup.FindFirst();
        QR := SN.CUInvoiceNo + '.png';
        SN.QRCode.Import(Setup.QRCodeStorage + QR);
        SN.Modify();

        SNRSetup.FindFirst();
        NS.LockTable();
        NS.Reset();
        NS.SetRange("Series Code", SNRSetup."Posted Shipment Nos.");
        if NS.FindFirst() then begin
            SN.ShipmentNo := INCSTR(NS."Last No. Used");
            SN.Modify();
            NS."Last No. Used" := SN.ShipmentNo;
            NS.Modify();
        end;
    end;

    procedure printShipment(SN: Record "Sales Invoice Header")
    var
        QR: Text[250];
        Setup: Record 51521060;
        NS: Record "No. Series Line";
        SNRSetup: Record "Sales & Receivables Setup";
    begin
        if SN.ShipmentNo = '' then begin
            SNRSetup.FindFirst();
            NS.LockTable();
            NS.Reset();
            NS.SetRange("Series Code", SNRSetup."Posted Shipment Nos.");
            if NS.FindFirst() then begin
                SN.ShipmentNo := INCSTR(NS."Last No. Used");
                SN.Modify();
                NS."Last No. Used" := SN.ShipmentNo;
                NS.Modify();
            end;
        end;


    end;


}
