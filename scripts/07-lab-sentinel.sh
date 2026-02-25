#!/bin/bash
set -e
RG_WORKLOAD="dr-lab-rg-workload"
echo "🔍 [AZURE LAB SENTINEL PRO] AUDITORÍA INICIADA"
echo "------------------------------------------------"

# 1. Chequeo de Recursos
VM_IP=$(az network public-ip show -g $RG_WORKLOAD -n dr-lab-pip-vm --query ipAddress -o tsv 2>/dev/null || echo "N/A")

if [ "$VM_IP" != "N/A" ]; then
    echo "📍 VM IP: $VM_IP"
    echo -n "🌐 APP STATUS: "
    curl -s --connect-timeout 2 http://$VM_IP > /dev/null && echo "✅ ONLINE" || echo "❌ OFFLINE"
else
    echo "📍 ESTADO: ⚪ AMBIENTE LIMPIO"
fi

echo "💰 PROYECCIÓN FINOPS: East US B1s (~\$0.012/h con Storage)"
echo "📋 RECURSOS ACTIVOS:"
az resource list -g $RG_WORKLOAD --query "[].{Name:name, Type:type, TTL:tags.TTL}" -o table 2>/dev/null || echo "Ninguno."
echo "------------------------------------------------"
