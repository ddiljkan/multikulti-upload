###############################################################################
# Required secrets
###############################################################################

variable "hcloud_token" {
  description = "Hetzner Cloud API token (Read & Write) for the target project."
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:DNS:Edit on the parent zone."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID of the parent domain (e.g. kud-mladost.org). Find it in the Cloudflare dashboard, right sidebar of the zone overview."
  type        = string
}

###############################################################################
# Naming & DNS
###############################################################################

variable "project_name" {
  description = "Short slug used to label Hetzner resources."
  type        = string
  default     = "multikulti-upload"
}

variable "hostname" {
  description = "Fully qualified hostname clubs will use to upload (must be a subdomain of the Cloudflare zone above)."
  type        = string
  default     = "multikulti-2026.kud-mladost.org"
}

variable "admin_email" {
  description = "Admin email — used by Caddy for Let's Encrypt account registration. Pingvin's admin account is created interactively on first visit."
  type        = string
  default     = "dejan.diljkan@outlook.com"
}

###############################################################################
# Hetzner server sizing & placement
###############################################################################

variable "hetzner_location" {
  description = "Hetzner datacenter location. fsn1 = Falkenstein, nbg1 = Nuremberg, hel1 = Helsinki."
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Hetzner server type. cx22 = 2 vCPU x86 / 4 GB / 40 GB / €4.49. cax11 = ARM equivalent at same price."
  type        = string
  default     = "cx22"
}

variable "server_image" {
  description = "OS image."
  type        = string
  default     = "ubuntu-24.04"
}

###############################################################################
# SSH access
###############################################################################

variable "ssh_public_key_path" {
  description = "Path to the SSH public key that will be authorised for the 'admin' user on the VPS."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH to the VPS. Default: open to the world (key-only). For tighter security, set to your home/office IPs."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "admin_username" {
  description = "Non-root Linux user created on the VPS."
  type        = string
  default     = "admin"
}

###############################################################################
# Backups
###############################################################################

variable "enable_hetzner_backups" {
  description = "Enable Hetzner's automatic backups (20% surcharge on server price). Daily snapshots kept for 7 days. Recommended on."
  type        = bool
  default     = true
}

###############################################################################
# Pingvin / Caddy
###############################################################################

variable "pingvin_image" {
  description = "Container image for Pingvin Share. Defaults to the upstream image — switch to the actively-maintained Pingvin Share X fork once you've confirmed its image path."
  type        = string
  default     = "stonith404/pingvin-share:latest"
}

variable "max_upload_size_mb" {
  description = "Maximum allowed upload body size at the Caddy layer."
  type        = number
  default     = 50
}
