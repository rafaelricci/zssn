json.reporter_id @report.reporter_id
json.reported do
  json.id @report.reported_id
  json.reports_from_reported_count @report.reports_from_reported_count
end
