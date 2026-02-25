#!/bin/bash
# 04-simulate-disaster.sh: Simula la destrucción de la VM comprometida.
set -e

RG="dr-lab-rg-workload"
VM_NAME="dr-lab-vm-app"

echo "🚨 INICIANDO SIMULACIÓN DE DESASTRE..."
echo "🛡️ Escenario: Ransomware detectado en la VM $VM_NAME."

# Eliminamos la VM para simular que debemos deshacernos de la infra infectada
az vm delete --resource-group $RG --name $VM_NAME --yes --no-wait

echo "✅ VM eliminada. La infraestructura ha sido contenida."
echo "💡 Siguiente paso: Usa Terraform para recrear la infraestructura limpia."
