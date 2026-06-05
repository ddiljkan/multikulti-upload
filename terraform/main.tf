###############################################################################
# Providers
###############################################################################

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

###############################################################################
# SSH key (uploaded to Hetzner project)
###############################################################################

resource "hcloud_ssh_key" "admin" {
  name       = "${var.project_name}-admin"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

###############################################################################
# Cloud-init bootstrap (Docker + Caddy + Pingvin + hardening)
###############################################################################

locals {
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    hostname           = var.hostname
    admin_email        = var.admin_email
    admin_username     = var.admin_username
    ssh_public_key     = trimspace(file(pathexpand(var.ssh_public_key_path)))
    pingvin_image      = var.pingvin_image
    max_upload_size_mb = var.max_upload_size_mb
  })
}

###############################################################################
# Firewall — only SSH (optionally restricted), HTTP, HTTPS
###############################################################################

resource "hcloud_firewall" "web" {
  name = "${var.project_name}-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ssh_allowed_cidrs
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

###############################################################################
# The VPS
###############################################################################

resource "hcloud_server" "app" {
  name        = "${var.project_name}-01"
  image       = var.server_image
  server_type = var.server_type
  location    = var.hetzner_location

  ssh_keys     = [hcloud_ssh_key.admin.id]
  firewall_ids = [hcloud_firewall.web.id]
  user_data    = local.cloud_init
  backups      = var.enable_hetzner_backups

  labels = {
    project = var.project_name
    role    = "app"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

###############################################################################
# Cloudflare DNS — A and AAAA, proxied
###############################################################################

resource "cloudflare_record" "app_v4" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  type    = "A"
  content = hcloud_server.app.ipv4_address
  ttl     = 1 # auto, required when proxied
  proxied = true
  comment = "Managed by Terraform — gig-upload-platform"
}

resource "cloudflare_record" "app_v6" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  type    = "AAAA"
  content = hcloud_server.app.ipv6_address
  ttl     = 1
  proxied = true
  comment = "Managed by Terraform — gig-upload-platform"
}
