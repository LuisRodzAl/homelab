#!/usr/bin/env bash
# ============================================================
# AUTO-SYNC SCRIPT PARA HOMELAB (GitOps Pull)
# Revisa cambios en origin/main cada intervalo y aplica
# docker compose up -d únicamente cuando hay commits nuevos.
# ============================================================

set -eo pipefail

HOMELAB_DIR="/home/luis/homelab"
LOG_DIR="${HOMELAB_DIR}/logs"
LOG_FILE="${LOG_DIR}/auto-sync.log"
LOCK_FILE="/tmp/homelab-auto-sync.lock"

# Asegurar directorio de logs
mkdir -p "${LOG_DIR}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}"
}

# Ejecución bajo lock para evitar ejecuciones concurrentes
exec 200>"${LOCK_FILE}"
if ! flock -n 200; then
    exit 0
fi

cd "${HOMELAB_DIR}"

# Asegurar que el entorno SSH conoce la llave de GitHub
export GIT_SSH_COMMAND="ssh -i /home/luis/.ssh/id_ed25519 -o BatchMode=yes"

# 1. Fetch silencioso de origin/main
if ! git fetch origin main --quiet 2>> "${LOG_FILE}"; then
    # Si no hay conexión o falla el fetch, salir sin romper nada
    exit 0
fi

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

# 2. Si no hay cambios, terminar silenciosamente
if [ "${LOCAL}" = "${REMOTE}" ]; then
    exit 0
fi

log "🚀 Nuevo commit detectado en origin/main (${REMOTE:0:7}). Iniciando sincronización..."

# 3. Descargar cambios
if ! git pull origin main --quiet >> "${LOG_FILE}" 2>&1; then
    log "❌ Error al hacer git pull. Abortando actualización."
    exit 1
fi

# 4. Validar sintaxis de docker compose antes de aplicar
if ! docker compose config --quiet >> "${LOG_FILE}" 2>&1; then
    log "❌ Error de validación en docker-compose.yml. Revirtiendo git pull..."
    git reset --hard "${LOCAL}" >> "${LOG_FILE}" 2>&1
    exit 1
fi

# 5. Aplicar cambios a los contenedores
log "🔄 Aplicando cambios con docker compose up -d..."
if docker compose up -d --remove-orphans >> "${LOG_FILE}" 2>&1; then
    log "✅ Homelab actualizado con éxito al commit ${REMOTE:0:7}."
else
    log "⚠️ docker compose up reportó advertencias o errores. Revisa los logs de los contenedores."
fi

# Mantener el log acotado (máximo 500 líneas)
if [ -f "${LOG_FILE}" ]; then
    tail -n 500 "${LOG_FILE}" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "${LOG_FILE}"
fi
