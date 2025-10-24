terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Create VPC
resource "digitalocean_vpc" "exploresg_vpc" {
  name     = "exploresg-vpc"
  region   = var.do_region
  ip_range = "10.10.0.0/16"
}

# Create SSH key
resource "digitalocean_ssh_key" "exploresg_key" {
  name       = "exploresg-key"
  public_key = file(var.ssh_public_key_path)
}

# Create droplet
resource "digitalocean_droplet" "exploresg_droplet" {
  name     = "exploresg-droplet"
  image    = "ubuntu-22-04-x64"
  region   = var.do_region
  size     = var.droplet_size
  vpc_uuid = digitalocean_vpc.exploresg_vpc.id

  ssh_keys = [digitalocean_ssh_key.exploresg_key.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3 python3-pip
    pip3 install ansible
  EOF

  tags = ["exploresg", "production"]
}

# Create firewall
resource "digitalocean_firewall" "exploresg_firewall" {
  name = "exploresg-firewall"

  droplet_ids = [digitalocean_droplet.exploresg_droplet.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "3000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8081-8084"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Create volume for database persistence
resource "digitalocean_volume" "exploresg_volume" {
  region                  = var.do_region
  name                    = "exploresg-db-volume"
  size                    = 20
  initial_filesystem_type = "ext4"
  description             = "PostgreSQL data volume for ExploreSG"
}

# Attach volume to droplet
resource "digitalocean_volume_attachment" "exploresg_volume_attachment" {
  droplet_id = digitalocean_droplet.exploresg_droplet.id
  volume_id  = digitalocean_volume.exploresg_volume.id
}

# Create floating IP
resource "digitalocean_floating_ip" "exploresg_floating_ip" {
  region     = var.do_region
  droplet_id = digitalocean_droplet.exploresg_droplet.id
}

# Outputs
output "droplet_ip" {
  value = digitalocean_droplet.exploresg_droplet.ipv4_address
}

output "floating_ip" {
  value = digitalocean_floating_ip.exploresg_floating_ip.ip_address
}

output "droplet_id" {
  value = digitalocean_droplet.exploresg_droplet.id
}

output "volume_id" {
  value = digitalocean_volume.exploresg_volume.id
}
