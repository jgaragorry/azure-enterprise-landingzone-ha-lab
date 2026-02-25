#!/bin/bash
# 06-full-cleanup.sh: Borra todo el laboratorio para evitar costos.
set -e

echo "⚠️ INICIANDO LIMPIEZA TOTAL DEL LABORATORIO..."

# 1. Destruir Workload vía Terraform
echo "🧹 Destruyendo Workload..."
cd terraform/environments/workload
terraform destroy -auto-approve -var-file=terraform.tfvars || echo "Ya borrado."

# 2. Destruir Landing Zone vía Terraform
echo "🧹 Destruyendo Landing Zone..."
cd ../landingzone
terraform apply -destroy -auto-approve -var-file=terraform.tfvars || echo "Ya borrado."

# 3. Borrar el Backend (Storage Account y RG del estado)
# Nota: Esto se hace con Azure CLI porque no es gestionado por el mismo Terraform
echo "🧹 Borrando infraestructura del Backend..."
# Buscamos el RG que empieza con rg-dr-backend
BACKEND_RG=$(az group list --query "[?contains(name, 'rg-dr-backend')].name" -o tsv)
if [ ! -z "$BACKEND_RG" ]; then
    az group delete --name $BACKEND_RG --yes --no-wait
    echo "✅ Solicitud de borrado de $BACKEND_RG enviada."
fi

echo "✨ Laboratorio totalmente limpio. ¡Buen trabajo!"
