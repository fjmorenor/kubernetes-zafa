output "enabled_apis" {
    value = [for svc in google_project_service.apis : svc.service]
}