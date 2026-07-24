terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "azurerm" {
  features {}

  # AzureRM 4.x requires an explicit subscription ID. Keep it in tfvars or
  # set TF_VAR_subscription_id; never commit a real tfvars file.
  subscription_id = var.subscription_id
}
