# Private GPU Windows 10 desktop in a browser (Terraform)

This repository is a **Terraform deployment scaffold**, not a free VPS service. It creates a private, browser-accessible [Azure Virtual Desktop (AVD)](https://learn.microsoft.com/azure/virtual-desktop/overview) personal desktop on a GPU-backed Azure VM:

```text
Your browser → https://client.wvd.microsoft.com → Azure Virtual Desktop broker → private Windows session host
                                                                        └─ NVIDIA A10 GPU
```

It deliberately creates **no public IP and no inbound RDP/3389 rule**. The published URL is the Microsoft AVD web client, where an entitled Microsoft Entra user signs in to the full desktop.

## Important reality check

A perpetual **free** Windows 10 VPS with a real gaming GPU and maximum CPU cores does not exist as a legitimate cloud offering. Windows licensing, a dedicated GPU, disks, outbound network traffic, and GPU capacity all cost money. This configuration has an explicit `confirm_paid_gpu_deployment = true` guard so it cannot create a GPU VM accidentally.

The default is `Standard_NV36ads_A10_v5`: **36 vCPUs and one NVIDIA A10 (24 GB) GPU** when that SKU is available. It is a high-end dedicated graphics configuration, but it is not a global “max cores” setting—actual limits are controlled by regional capacity and the quota on the Azure subscription. Check Azure pricing and quota yourself immediately before deployment.

Also note:

- The default image is **Windows 10 Enterprise multi-session Gen2**, suitable for AVD—not Windows 10 Home/Pro. Windows 10 reached end of support on **October 14, 2025**; use a supported Windows 11 AVD image for a new long-lived deployment unless a Windows 10 enterprise lifecycle entitlement specifically requires it.
- Azure Virtual Desktop access and the Windows image both have licensing requirements. Confirm your entitlement or per-user AVD access pricing with Microsoft/Azure before applying.
- GPU rendering and H.264/AVC hardware encoding are configured, but smooth remote graphics depend heavily on the route, browser/device decode support, display resolution, and latency. Southeast Asia is the default region because it is usually geographically close to Vietnam, not because GPU capacity is guaranteed there.
- A VM is not a way to bypass game licensing, DRM, cloud-gaming restrictions, or anti-cheat. Some games simply will not run in a virtual machine or remote desktop session. This project does not bypass those controls.

## What Terraform creates

| Component | Purpose |
| --- | --- |
| Resource group, VNet, private subnet, NSG | Network isolation. There is no public IP or public inbound rule. |
| Personal AVD host pool, desktop application group, workspace | Publishes one full desktop in the web client. A personal pool gives the user a dedicated host rather than a shared session host. |
| `Standard_NV36ads_A10_v5` Windows VM by default | A real Azure NV-series GPU VM, with a Premium SSD OS disk and accelerated networking. Change `vm_size` only after checking regional support. |
| `NvidiaGpuDriverWindows` extension | Installs the NVIDIA driver supported by Azure for the selected NV GPU VM. |
| `AADLoginForWindows` + AVD registration extension | Microsoft Entra joins the host and registers it to the AVD host pool using a short-lived token. |
| GPU tuning managed run command | Verifies `nvidia-smi`, enables Windows RDS hardware rendering/H.264 settings, then schedules one reboot. |
| Entra role assignments | Grants the selected user or group `Desktop Virtualization User` and `Virtual Machine User Login`. |

## Prerequisites

1. An Azure subscription that can create paid NV-series GPU VMs and AVD resources.
2. **GPU quota and capacity** for the selected region and SKU. New subscriptions commonly have zero GPU quota.
3. A Microsoft Entra user or security group that will be permitted to open the desktop.
4. Terraform 1.7+ and Azure CLI logged into the target subscription.
5. Permissions to create resource groups, role assignments, virtual machines, and AVD resources. Creating role assignments normally requires `Owner` or `User Access Administrator` at the relevant scope.

Install Terraform and Azure CLI from their official sources, then authenticate:

```bash
az login
az account set --subscription "<your-subscription-id>"
az account show --query id --output tsv
```

Before editing Terraform variables, check whether the requested GPU shape exists in your intended region and whether the subscription has quota:

```bash
# SKU availability/capacity is regional and changes over time.
az vm list-skus \
  --location southeastasia \
  --resource-type virtualMachines \
  --size Standard_NV36ads_A10_v5 \
  --all \
  --output table

# Look for the NVadsA10 v5 family quota and current usage.
az vm list-usage --location southeastasia --output table
```

If it is unavailable, do **not** blindly change regions or SKU sizes. First choose a region with acceptable latency and available capacity, request the matching GPU family quota in Azure Portal **Quotas**, and update `location`/`vm_size` together.

## Configure

Create a local variables file. It is ignored by Git so IDs and other local values do not get committed:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Find the object ID of the Entra user who will use the browser desktop, or preferably of a security group:

```bash
# Signed-in user's Entra object ID
az ad signed-in-user show --query id --output tsv

# Or query an existing security group
az ad group show --group "<group-display-name-or-id>" --query id --output tsv
```

Update `terraform.tfvars` with the subscription ID and the Entra object ID. Keep the paid-deployment switch false until all checks are complete.

Do **not** put the Windows local administrator password in a file. Supply it through your shell instead (use a unique 20+ character value):

```bash
export TF_VAR_admin_password='replace-with-a-unique-long-password'
```

> Terraform state records sensitive resource inputs, including the short-lived AVD registration material. Before any real deployment, use an encrypted, access-controlled [remote Terraform backend](https://developer.hashicorp.com/terraform/language/backend/azurerm) and never commit state or `.tfvars` files. This repository’s `.gitignore` excludes them.

## Deploy

First validate the configuration without creating anything:

```bash
terraform init
terraform fmt -check
terraform validate
```

After you have confirmed Azure costs, quota, regional capacity, licensing, and the exact variables, change this in `terraform.tfvars`:

```hcl
confirm_paid_gpu_deployment = true
```

Then review and apply the exact plan:

```bash
terraform plan -out gpu-desktop.tfplan
terraform apply gpu-desktop.tfplan
```

Provisioning can take several minutes. The NVIDIA driver extension, AVD agent registration, and final reboot happen after the VM is created. Do not open public RDP as a workaround—there is intentionally no public endpoint.

## Open the published web desktop

After Terraform finishes and the session host shows **Available** (allow several additional minutes after the scheduled reboot), open:

**https://client.wvd.microsoft.com/arm/webclient/index.html**

Sign in with the Microsoft Entra user that belongs to the configured object/group. The workspace exposes **Personal GPU Desktop**; select it to start the full desktop in the browser.

The web client is the URL-based access requested here. For demanding interactive graphics, test Microsoft’s native Remote Desktop client too—it can perform better than a browser depending on the local device and network. The VM remains private either way.

Useful post-deployment checks:

```bash
RG="$(terraform output -raw resource_group_name)"
POOL="$(terraform output -raw host_pool_name)"
VM="$(terraform output -raw primary_session_host_name)"

# The host should become Available after AVD registration and reboot.
az desktopvirtualization session-host list \
  --resource-group "$RG" \
  --host-pool-name "$POOL" \
  --output table

# Verify that the actual NVIDIA driver sees a GPU without opening RDP.
az vm run-command invoke \
  --resource-group "$RG" \
  --name "$VM" \
  --command-id RunPowerShellScript \
  --scripts '& "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe"'
```

If registration is not `Available`, inspect the VM extensions in Azure Portal and the AVD agent logs. A common cause is a missing/expired registration token or an Entra/role-assignment propagation delay. The [Microsoft guide for adding session hosts](https://learn.microsoft.com/azure/virtual-desktop/add-session-hosts-host-pool) and the [AVD GPU acceleration guidance](https://learn.microsoft.com/azure/virtual-desktop/graphics-enable-gpu-acceleration) are the authoritative troubleshooting references.

## Cost control and cleanup

A GPU VM keeps incurring compute charges while it is running. Deallocating it stops VM compute charges but **does not** remove managed-disk, IP (if any), backup, or other resource costs:

```bash
az vm deallocate --resource-group "$RG" --name "$VM"
```

To remove every resource this configuration owns, including the GPU VM and its disk, use:

```bash
terraform destroy
```

Review the destroy plan carefully. This is destructive and removes the Windows VM and its local data.

## Customization

- To use a smaller/cheaper GPU partition, set a supported NVads A10 v5 SKU in `vm_size` after validating quota and capacity. It remains paid.
- To use Windows 11 instead of the requested Windows 10, override `windows_image` with a currently supported Azure Virtual Desktop image from Azure Marketplace.
- `session_host_count` defaults to `1` because this is a personal desktop. Each additional host is a separate billed GPU VM; it does not add CPU cores to one desktop.
- Store game libraries or large project files on intentionally managed data disks or a profile solution. The supplied OS disk is only 256 GiB by default.
- Do not weaken the private-network design by adding a public IP or port 3389. Use the AVD web client/Remote Desktop client and Entra access controls instead.
