locals {
  tags = {
    Environment = "lab"
    Project     = "disaster-recovery"
    Owner       = "jgaragorry"
    TTL         = "2026-02-24T17:00:00Z"
    Compliance  = "finops-sre-security"
    ManagedBy   = "terraform"
  }
}

data "azurerm_resource_group" "workload" { 
  name = var.resource_group_name 
}

# --- RED Y SEGURIDAD ---

resource "azurerm_network_security_group" "vm_sg" {
  name                = "${var.prefix}-nsg-web"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.workload.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.prefix}-nic-vm"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.workload.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm_sg.id
}

# --- MÁQUINA VIRTUAL ---

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-vm-app"
  resource_group_name = data.azurerm_resource_group.workload.name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm.id]
  
  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCe29w2VO8pljZ/au1qoAXQ5oH1MnXg0wiawkMTCZKcT5NPfH/H/HN7cYkm3T5MNghLUenItr+eW3aLxI3uO852RgozgHXVn/gbU2WfplBDMvTyL056PrMFHRBGxW9CJWAYHe4fs1toviDoIB1DX2C5UbWQ/pklhFiEicV1SkL7+SkYRHbz/uuxoQqeCxHMeNNGmQMYkZFf1yYA4HwwruwfnJ5BIuPzT02HKlc5Wvorqp7Dkm9EauStfFi/JYPpZCVPusQojYeq4/diK3pGCQYaOXUOwS7h6Vhyw/fPfMbROfw3kw3dzSi2+MFZfw46cEtFZlJKi+1TWKkBT6S8JPtAvPJcXaGSaKZYJZdjh+7UHV54ygODqKiUtl0p9y+1uU1C1/dvT0913tt3pkvwc90z00+VHnKM74j4gEEq5sG45fIa+oyBsX9gm0oUG8yDdFtumTvorxtlrFQSp/DYc31fOUKoEUp2KfL/aNe7cgZ3Y+5PhhcTx+vhy501qrr4PTJG0O+XOdZhuzGWDGcAfY37na/BpY3R9TQ5EKwhIhXLUBOr0YOgQheWuIvRSpId6sSX0xslB0gRqON9McvwHQ8bcCE2B3956ONBm+M0OS6iEzHrS+n3vpLmtq17sfzMzA8o1Ouls7s3fHOu1igZo6Zpi3f0eMAXaYCUtUwL6sL7JQ== gmt@MSI"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.tags

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              echo "<html><body style='background-color: #0078D4; color: white; font-family: sans-serif; text-align: center; padding-top: 100px;'><h1>🛡️ Disaster Recovery Lab</h1><p>Aplicación Activa en Azure - José Garagorry</p><p>Estado: <b>FUNCIONAL</b></p></body></html>" > /var/www/html/index.html
              EOF
  )
}

# --- BACKUP ---

resource "azurerm_recovery_services_vault" "vault" {
  name                = "${var.prefix}-rsv-backup"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.workload.name
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = local.tags
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "${var.prefix}-policy"
  resource_group_name = data.azurerm_resource_group.workload.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "vm" {
  resource_group_name = data.azurerm_resource_group.workload.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = azurerm_linux_virtual_machine.vm.id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
