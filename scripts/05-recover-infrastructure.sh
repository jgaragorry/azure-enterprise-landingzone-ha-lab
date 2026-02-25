#!/bin/bash
# 05-recover-infrastructure.sh: Reconstruye la infraestructura base limpia.
set -e

echo "🛠️ RECONSTRUYENDO INFRAESTRUCTURA DESDE ESTADO LIMPIO..."

cd terraform/environments/workload
terraform apply -auto-approve -var-file=terraform.tfvars

echo "✅ Infraestructura recreada con éxito."
echo "🔄 Ahora procede al Portal de Azure para restaurar el disco desde el Recovery Services Vault."  
