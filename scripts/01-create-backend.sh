#!/bin/bash
set -euo pipefail

SUB_ID=$ARM_SUBSCRIPTION_ID
LOCATION="eastus"
SHORT_PREFIX="dr$(date +%s | cut -c1-8)"  # dr + 8 dígitos = 10 chars

echo "🟢 Backend RG: rg-dr-backend-$SHORT_PREFIX"
az group create --name "rg-dr-backend-$SHORT_PREFIX" --location $LOCATION \
  --tags "Environment=lab" "Project=disaster-recovery" "TTL=4h" "Owner=jgaragorry" || true

echo "🟢 Backend Storage: drbk$SHORT_PREFIX"
az storage account create \
  --name "drbk$SHORT_PREFIX" \
  --resource-group "rg-dr-backend-$SHORT_PREFIX" \
  --location $LOCATION \
  --sku Standard_LRS \
  --tags "Backend=terraform" "TTL=4h" || true

az storage container create --name tfstate --account-name "drbk$SHORT_PREFIX" || true

cat << EOF
✅ Backend listo!
RG: rg-dr-backend-$SHORT_PREFIX
SA: drbk$SHORT_PREFIX

Variables para terraform:
export TF_BACKEND_RG=rg-dr-backend-$SHORT_PREFIX
export TF_BACKEND_SA=drbk$SHORT_PREFIX
