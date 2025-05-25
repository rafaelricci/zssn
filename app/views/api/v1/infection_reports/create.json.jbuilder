json.reporter_id @report.reporter_id
json.reported do
  json.id @report.reported_id
  json.reports_received_count @report.reports_received_count
end
