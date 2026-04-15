output "email" {
  description = "El email de la cuenta creada para usarlo en otros sitios"
  value = google_service_account.static_sa.email
}