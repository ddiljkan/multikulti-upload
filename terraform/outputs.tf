output "server_id" {
  description = "Hetzner server ID."
  value       = hcloud_server.app.id
}

output "server_name" {
  description = "Hetzner server name."
  value       = hcloud_server.app.name
}

output "ipv4_address" {
  description = "Public IPv4 of the VPS (origin — Cloudflare proxies in front of this)."
  value       = hcloud_server.app.ipv4_address
}

output "ipv6_address" {
  description = "Public IPv6 of the VPS."
  value       = hcloud_server.app.ipv6_address
}

output "ssh_command" {
  description = "Ready-to-paste SSH command."
  value       = "ssh ${var.admin_username}@${hcloud_server.app.ipv4_address}"
}

output "url" {
  description = "Public URL once cloud-init has finished (give it ~3 minutes after apply)."
  value       = "https://${var.hostname}"
}
