#!/bin/bash
# 08-purge-backend.sh: Purga total del estado remoto y limpieza local.
set -e

echo "⚠️ INICIANDO PURGA TOTAL DEL BACKEND..."

# 1. Buscar y eliminar el Resource Group del Backend (Búsqueda flexible)
# Buscamos cualquier grupo que contenga "rg-dr" y "backend" al mismo tiempo
RG_BACKEND=$(az group list --query "[?contains(name, 'rg-dr') && contains(name, 'backend')].name" -o tsv)

if [ ! -z "$RG_BACKEND" ]; then
    for rg in $RG_BACKEND; do
        echo "🗑️ Eliminando Resource Group encontrado: $rg..."
        az group delete --name "$rg" --yes --no-wait
        echo "✅ Solicitud enviada para: $rg"
    done
else
    echo "ℹ️ No se encontró ningún Resource Group de backend activo."
fi

# 2. Limpieza de higiene local (Esto ya funcionaba bien)
echo "🧹 Limpiando archivos de estado locales y temporales..."
find . -name "*.tfstate" -type f -delete
find . -name "*.tfstate.backup" -type f -delete
find . -name ".terraform" -type d -exec rm -rf {} +

echo "✨ Sistema 100% limpio. Facturación protegida."
