# 📖 Disaster Recovery Playbook: Operación Resiliencia Azure

![Status](https://img.shields.io/badge/Status-Production--Ready-success?style=for-the-badge)
![Complexity](https://img.shields.io/badge/Complexity-Intermediate-yellow?style=for-the-badge)
![Environment](https://img.shields.io/badge/Environment-Azure_Cloud-blue?style=for-the-badge)

Este documento detalla los procedimientos operativos estándar (SOP) para el despliegue, simulación de fallas, recuperación y desmantelamiento del laboratorio de Disaster Recovery.

---

## 🛠️ Fase 00: Pre-requisitos y Verificación

Antes de iniciar, debemos asegurar que el entorno de control (tu máquina) tiene las herramientas necesarias.

- **Herramientas:** Terraform >= 1.6, Azure CLI, Llave SSH RSA 4096.
- **Permisos:** Rol de `Contributor` o `Owner` sobre la suscripción.
```bash
# Ejecución del Pre-check (Idempotente)
bash scripts/00-pre-check.sh
```

Este script valida que estés logueado en Azure y que no existan conflictos de variables de entorno.

---

## 🏗️ Fase 01: Infraestructura de Persistencia (Backend)

El Backend es inamovible. Almacena el "estado" (memoria) de Terraform en la nube para protegerlo.

**Ejecutar Creación:**
```bash
bash scripts/01-create-backend.sh
```

- **Resultado:** Crea un Resource Group y un Storage Account con nombres aleatorios únicos para evitar colisiones.
- **Idempotencia:** Si el script se corre de nuevo, detectará que los recursos existen y solo refrescará las variables.

---

## 🚀 Fase 02: Despliegue de Infraestructura (Landing Zone & Workload)

Seguimos el orden de dependencias: primero la red, luego el cómputo.

**Step 2.1: Landing Zone (La Red)**
```bash
cd terraform/environments/landingzone
terraform init && terraform apply -auto-approve -var-file=terraform.tfvars
```

**Verificación:** Aparece el grupo `dr-lab-rg-workload` con la VNet y Subnets.

**Step 2.2: Workload (La Aplicación)**
```bash
cd ../workload
terraform init && terraform apply -auto-approve -var-file=terraform.tfvars
```

**Verificación:** La VM B1s se crea e instala automáticamente el servidor web Apache.

---

## 📊 Fase 03: Monitoreo y Validación de Salud

Usamos el Sentinel para confirmar que la aplicación está viva antes de la prueba.
```bash
bash scripts/07-lab-sentinel.sh
```

- **Evidencia:** El Sentinel debe marcar `APP STATUS: ✅ ONLINE`.
- **Prueba Visual:** Abre la IP pública en tu navegador. Deberás ver la pantalla azul con el mensaje: *"Estado: FUNCIONAL"*.

---

## 🌪️ Fase 04: Simulación de Desastre (Ransomware)

**El Escenario:** Un atacante ha cifrado la VM y debemos destruirla para contener la propagación del malware.
```bash
bash scripts/04-simulate-disaster.sh
```

- **¿Qué sucede?** Se elimina quirúrgicamente la VM del Resource Group.
- **Impacto:** El Sentinel marcará `❌ OFFLINE` y la web dejará de cargar. El negocio se detiene.

---

## 🩹 Fase 05: Plan de Recuperación de Desastres (DRP)

Recuperamos el servicio basándonos en la **Inmutabilidad del Código** y los **Backups**.

**Reaprovisionamiento:**
```bash
bash scripts/05-recover-infrastructure.sh
```

- **¿Por qué funciona?** Terraform lee el Backend remoto, detecta que la VM "física" no existe pero el "código" dice que debería estar. Recrea la VM con las llaves SSH y configuraciones originales.
- **Restauración de Datos:** (Conceptualmente) Se accede al Recovery Services Vault para montar el snapshot del disco previo al ataque.
- **Validación:** Ejecuta `07-lab-sentinel.sh`. La web debe volver a estar `✅ ONLINE`.

---

## 🧹 Fase 06: Ciclo de Limpieza (FinOps)

Para garantizar una facturación de **$0 USD**, debemos limpiar todo rastro de recursos.

**Step 6.1: Limpieza del Laboratorio**
```bash
bash scripts/06-full-cleanup.sh
```

- **Tiempo estimado:** 3 a 5 minutos.
- **Resultado:** Elimina el Workload y la Landing Zone. El portal de Azure queda limpio excepto por el Backend.

**Step 6.2: Purga Total (Eliminar Backend)**

Si ya no vas a realizar más pruebas, debes eliminar la "Caja Fuerte". Para esto crearemos un script final:
```bash
# Crear script de purga final
cat > scripts/08-purge-backend.sh << 'EOF'
#!/bin/bash
# 08-purge-backend.sh: Elimina el Storage Account del estado de Terraform.
RG_BACKEND=$(az group list --query "[?contains(name, 'rg-dr-backend')].name" -o tsv)
if [ ! -z "$RG_BACKEND" ]; then
    echo "⚠️ ELIMINANDO BACKEND: $RG_BACKEND..."
    az group delete --name $RG_BACKEND --yes --no-wait
    echo "✨ Azure quedará en 0 recursos en unos minutos."
fi
EOF
chmod 750 scripts/08-purge-backend.sh

# Ejecutar:
bash scripts/08-purge-backend.sh
```

---

## 💰 Conclusión FinOps

Al finalizar todas las fases y ejecutar el script `08`, tu factura de Azure no recibirá cargos adicionales. Hemos aplicado un ciclo de vida completo de SRE:

**Provisión → Operación → Falla → Recuperación → Limpieza**

---

> Elaborado por: **José Garagorry** | SRE & Cloud Architect 🇨🇱
