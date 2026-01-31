# Hardware Gateway VM
resource "oci_core_instance" "hardware_gateway" {
  # ... existing configuration ...

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(templatefile("${path.module}/user_data_hardware.sh", {
      GITHUB_REPO = var.github_repo
    }))
  }
}

# Build Server VM
resource "oci_core_instance" "build_server" {
  # ... existing configuration ...

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(templatefile("${path.module}/user_data_build.sh", {
      GITHUB_REPO = var.github_repo
    }))
  }
}
