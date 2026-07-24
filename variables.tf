variable "subscription_id" {
  description = "Azure subscription ID that will be billed for this deployment."
  type        = string
  sensitive   = true
}

variable "name_prefix" {
  description = "Short lowercase identifier used in Azure resource names."
  type        = string
  default     = "gpuavd"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.name_prefix))
    error_message = "name_prefix must be 3-20 lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Short environment label used in Azure resource names."
  type        = string
  default     = "personal"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "environment must be 2-12 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region. southeastasia is close to Vietnam, but GPU SKU capacity and quota must be checked before applying."
  type        = string
  default     = "southeastasia"
}

variable "avd_user_or_group_object_id" {
  description = "Microsoft Entra user or security-group object ID that may open the published desktop. Use a group ID where possible."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.avd_user_or_group_object_id))
    error_message = "avd_user_or_group_object_id must be a Microsoft Entra object ID (a GUID)."
  }
}

variable "admin_username" {
  description = "Break-glass local Windows administrator name. This account is not the normal AVD sign-in account."
  type        = string
  default     = "avdadmin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_-]{2,19}$", var.admin_username))
    error_message = "admin_username must be 3-20 characters, start with a letter, and contain only letters, numbers, underscores, or hyphens."
  }
}

variable "admin_password" {
  description = "Strong local administrator password. Supply with TF_VAR_admin_password instead of committing it to a tfvars file."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 20
    error_message = "admin_password must be at least 20 characters."
  }
}

variable "session_host_count" {
  description = "Number of dedicated GPU session hosts. One is normally right for a personal desktop. Every host incurs GPU VM charges."
  type        = number
  default     = 1

  validation {
    condition     = var.session_host_count >= 1 && var.session_host_count <= 10
    error_message = "session_host_count must be between 1 and 10."
  }
}

variable "vm_size" {
  description = "Azure GPU VM SKU. Standard_NV36ads_A10_v5 is 36 vCPUs with one NVIDIA A10 GPU; it is not free and needs quota/capacity."
  type        = string
  default     = "Standard_NV36ads_A10_v5"
}

variable "os_disk_size_gb" {
  description = "Premium SSD OS disk size in GiB. Game libraries should use separately managed data disks, not the OS disk."
  type        = number
  default     = 256

  validation {
    condition     = var.os_disk_size_gb >= 128 && var.os_disk_size_gb <= 4095
    error_message = "os_disk_size_gb must be between 128 and 4095."
  }
}

variable "windows_image" {
  description = "Marketplace image for Azure Virtual Desktop. The default is Windows 10 Enterprise multi-session Gen2 as requested."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "win10-22h2-avd-g2"
    version   = "latest"
  }
}

variable "avd_dsc_modules_url" {
  description = "Microsoft AVD DSC configuration package that installs/registers the AVD agent. Override only with a tested Microsoft-published package."
  type        = string
  default     = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02714.342.zip"
}

variable "confirm_paid_gpu_deployment" {
  description = "Safety acknowledgement. Set true only after checking Azure quota, capacity, licensing, and current pricing. A GPU VM cannot be deployed while false."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
