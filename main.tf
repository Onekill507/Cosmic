locals {
  deployment_name = lower("${var.name_prefix}-${var.environment}")

  # Windows computer names must remain short. The numeric key also makes a
  # replaced session host get a predictable, unique computer name.
  vm_name_prefix = substr(replace(local.deployment_name, "/[^a-z0-9]/", ""), 0, 10)

  session_hosts = {
    for index in range(var.session_host_count) :
    format("%02d", index + 1) => {
      index = index + 1
    }
  }

  common_tags = merge({
    managed-by  = "terraform"
    workload    = "azure-virtual-desktop"
    access      = "browser-only-no-public-ip"
    gpu-profile = var.vm_size
  }, var.tags)
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.deployment_name}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.deployment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.60.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "session_hosts" {
  name                 = "snet-session-hosts"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.60.10.0/24"]
}

# The VM has no public IP and this NSG has no public inbound allow rule.
# AVD brokers the browser connection over outbound HTTPS, so opening RDP/3389
# to the Internet is neither required nor desirable.
resource "azurerm_network_security_group" "session_hosts" {
  name                = "nsg-${local.deployment_name}-session-hosts"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "session_hosts" {
  subnet_id                 = azurerm_subnet.session_hosts.id
  network_security_group_id = azurerm_network_security_group.session_hosts.id
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                              = "hp-${local.deployment_name}"
  location                          = azurerm_resource_group.this.location
  resource_group_name               = azurerm_resource_group.this.name
  type                              = "Personal"
  load_balancer_type                = "Persistent"
  personal_desktop_assignment_type = "Automatic"
  preferred_app_group_type          = "Desktop"
  friendly_name                     = "${var.name_prefix} personal GPU desktop"
  description                       = "Dedicated GPU-backed Windows desktop provisioned with Terraform."

  # targetisaadjoined is needed for Microsoft Entra ID joined session hosts.
  # The remaining settings favor responsive media/graphics while letting the
  # client adapt to available bandwidth.
  custom_rdp_properties = join(";", [
    "targetisaadjoined:i:1",
    "audiomode:i:0",
    "audiocapturemode:i:1",
    "redirectclipboard:i:1",
    "redirectcomports:i:0",
    "drivestoredirect:s:",
    "use multimon:i:0",
    "videoplaybackmode:i:1",
    "networkautodetect:i:1",
    "bandwidthautodetect:i:1",
    "enablecredsspsupport:i:1",
  ])

  tags = local.common_tags
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = "dag-${local.deployment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  friendly_name       = "Personal GPU Desktop"
  description         = "Full Windows desktop published through Azure Virtual Desktop."
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = "ws-${local.deployment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  friendly_name       = "${var.name_prefix} GPU Workspace"
  description         = "Browser-accessible personal Azure Virtual Desktop workspace."
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "desktop" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

# Give the selected Entra user/group both an AVD desktop entitlement and the
# OS sign-in entitlement required by Microsoft Entra joined Windows hosts.
resource "azurerm_role_assignment" "avd_desktop_user" {
  scope                = azurerm_virtual_desktop_application_group.desktop.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.avd_user_or_group_object_id
}

resource "azurerm_role_assignment" "vm_user_login" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = var.avd_user_or_group_object_id
}

# The token is deliberately short lived. It is used only to register a new
# session host, not for end-user access. Keep Terraform state encrypted because
# the registration resource is sensitive.
resource "time_rotating" "registration_token" {
  rotation_hours = 24
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = timeadd(time_rotating.registration_token.rotation_rfc3339, "24h")
}

resource "azurerm_network_interface" "session_host" {
  for_each                       = local.session_hosts
  name                           = "nic-${local.deployment_name}-${each.key}"
  location                       = azurerm_resource_group.this.location
  resource_group_name            = azurerm_resource_group.this.name
  accelerated_networking_enabled = true
  tags                           = local.common_tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.session_hosts.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "session_host" {
  for_each            = local.session_hosts
  name                = "${local.vm_name_prefix}-${each.key}"
  computer_name       = "${local.vm_name_prefix}-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  size                = var.vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [azurerm_network_interface.session_host[each.key].id]

  # Required by the AADLoginForWindows extension and useful for workload
  # identity later. End users authenticate with Entra, not this identity.
  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.windows_image.publisher
    offer     = var.windows_image.offer
    sku       = var.windows_image.sku
    version   = var.windows_image.version
  }

  boot_diagnostics {}
  tags = local.common_tags

  lifecycle {
    # GPU VM capacity, Windows licensing, managed disks, and outbound traffic
    # are billable. This stops an accidental paid deployment by default.
    precondition {
      condition     = var.confirm_paid_gpu_deployment
      error_message = "Set confirm_paid_gpu_deployment = true only after accepting the paid Azure GPU, disk, network, and Windows/AVD licensing costs. There is no perpetual free GPU Windows VPS."
    }
  }
}

# Microsoft Entra ID join; no traditional domain controller or public RDP
# endpoint is required for this personal desktop.
resource "azurerm_virtual_machine_extension" "aad_login" {
  for_each                   = local.session_hosts
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[each.key].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

# Azure's NVIDIA extension installs the driver matched to the selected NV GPU
# VM. It does not turn a CPU VM into a GPU VM: vm_size must be an available NV
# SKU in the chosen region.
resource "azurerm_virtual_machine_extension" "nvidia_driver" {
  for_each                   = local.session_hosts
  name                       = "NvidiaGpuDriverWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[each.key].id
  publisher                  = "Microsoft.HpcCompute"
  type                       = "NvidiaGpuDriverWindows"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
}

# Installs the AVD agent/boot loader and registers the Entra-joined host using
# the short-lived token. The token is sent as protected extension settings.
resource "azurerm_virtual_machine_extension" "avd_registration" {
  for_each                   = local.session_hosts
  name                       = "AVDSessionHostRegistration"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[each.key].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = var.avd_dsc_modules_url
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      hostPoolName = azurerm_virtual_desktop_host_pool.this.name
      aadJoin      = true
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.this.token
    }
  })

  # Azure does not read protected settings back. The token also rotates after
  # deployment; existing hosts do not need to be re-registered for that alone.
  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    azurerm_virtual_machine_extension.aad_login,
    azurerm_role_assignment.vm_user_login,
  ]
}

# Applies the documented RDS policy registry settings that allow rendering and
# H.264/AVC encoding to use the installed GPU. The script verifies NVIDIA first
# and schedules one reboot; a driver reboot is required before use.
resource "azurerm_virtual_machine_run_command" "gpu_tuning" {
  for_each           = local.session_hosts
  name               = "ConfigureGpuAvd"
  location           = azurerm_resource_group.this.location
  virtual_machine_id = azurerm_windows_virtual_machine.session_host[each.key].id

  source {
    script = file("${path.module}/scripts/Configure-GpuAvd.ps1")
  }

  depends_on = [
    azurerm_virtual_machine_extension.nvidia_driver,
    azurerm_virtual_machine_extension.avd_registration,
  ]
}
