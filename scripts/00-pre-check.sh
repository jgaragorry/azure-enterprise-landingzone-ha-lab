# Script de pre-check (copia esto a tu repo en /scripts/pre-check.sh)
#!/bin/bash
echo "=== AZURE DR LAB - PRE-CHECK (idempotente) ==="
# Terraform
if ! command -v terraform &> /dev/null; then echo "❌ Instala Terraform >=1.6"; exit 1; fi
terraform --version | head -1

# Azure CLI
if ! command -v az &> /dev/null; then echo "❌ Instala Azure CLI"; exit 1; fi
az --version | head -1

# Git
git --version

# Docker (opcional para futuras automatizaciones)
command -v docker &> /dev/null && echo "✅ Docker OK" || echo "⚠️ Docker opcional"

# Variables de entorno requeridas
if [[ -z "$ARM_SUBSCRIPTION_ID" ]]; then echo "❌ Set ARM_SUBSCRIPTION_ID"; exit 1; fi
echo "✅ Subscription ID: $ARM_SUBSCRIPTION_ID"

