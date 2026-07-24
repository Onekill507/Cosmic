output "web_client_url" {
  description = "Open this URL in a modern browser, sign in with the entitled Microsoft Entra account, then select Personal GPU Desktop."
  value       = "https://client.wvd.microsoft.com/arm/webclient/index.html"
}

output "workspace_name" {
  description = "Azure Virtual Desktop workspace that publishes the desktop to the web client."
  value       = azurerm_virtual_desktop_workspace.this.name
}

output "host_pool_name" {
  description = "Personal Azure Virtual Desktop host pool name."
  value       = azurerm_virtual_desktop_host_pool.this.name
}

output "resource_group_name" {
  description = "Resource group containing the AVD resources and private GPU session host(s)."
  value       = azurerm_resource_group.this.name
}

output "session_host_names" {
  description = "Private GPU session-host VM names. They have no public IP addresses."
  value       = { for key, vm in azurerm_windows_virtual_machine.session_host : key => vm.name }
}

output "primary_session_host_name" {
  description = "First personal GPU session host name, convenient for Azure CLI verification commands."
  value       = azurerm_windows_virtual_machine.session_host["01"].name
}

output "gpu_vm_size" {
  description = "Requested GPU VM SKU. Confirm actual availability and quota in the chosen region before applying."
  value       = var.vm_size
}
