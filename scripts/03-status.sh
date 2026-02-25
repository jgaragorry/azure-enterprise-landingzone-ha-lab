#!/bin/bash
RG="dr-lab-rg-workload"
echo "=== DR LAB STATUS ==="
az group show --name $RG --query "{Status:properties.provisioningState, Location:location}" -o table
az network vnet list --resource-group $RG --query "[].{Name:name, AddressSpace:addressSpace}" -o table
echo "✅ Lab running"
