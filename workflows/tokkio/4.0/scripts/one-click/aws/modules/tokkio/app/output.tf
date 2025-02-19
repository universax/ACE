
output "app_instance" {
  value = module.app_instance
}
output "private_ips" {
  value = [for instance_suffix in var.instance_suffixes : module.app_instance[instance_suffix].private_ip]
}
output "ui_endpoint" {
  value = "https://${local.ui_domain}"
}
output "api_endpoint" {
  value = "https://${local.api_domain}"
}
output "elasticsearch_endpoint" {
  value = "https://${local.elastic_domain}"
}
output "kibana_endpoint" {
  value = "https://${local.kibana_domain}"
}
output "grafana_endpoint" {
  value = "https://${local.grafana_domain}"
}