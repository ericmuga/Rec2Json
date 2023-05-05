codeunit 51520050 "Sub Report"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', true, true)]
    local procedure MyProcedure(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::"Standard Sales - Invoice" then NewReportId := Report::"Standard Sales - InvoiceAL";
        if ReportId = Report::"Standard Sales - Credit Memo" then NewReportId := Report::"Standard Sales - Credit MemoAL";
        if ReportId = 50187 then NewReportId := 51520057;
        // if ReportId = 207 then NewReportId := Report::"Standard Sales - InvoiceAL";

    end;
}
// 