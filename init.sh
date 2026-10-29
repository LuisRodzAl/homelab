#!/usr/bin/env bash
# ============================================================
# SCRIPT DE INICIALIZACIÓN DEL HOMELAB
# Prepara carpetas de datos persistentes y variables de entorno
# ============================================================

set -e

echo "🚀 Iniciando preparación del entorno Homelab..."

# 1. Comprobar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado. Instálalo primero con: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

# 2. Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo "📄 Creando archivo .env desde plantilla env.example..."
    cp env.example .env
    echo "⚠️  IMPORTANTE: Edita el archivo .env y configura tus contraseñas y claves antes de levantar el stack."
else
    echo "✅ Archivo .env ya existente."
fi

# 3. Crear estructura de datos persistentes (data/)
echo "📁 Creando estructura de directorios persistentes en ./data/..."
mkdir -p data/pihole/etc-pihole
mkdir -p data/pihole/etc-dnsmasq.d
mkdir -p data/npm/data
mkdir -p data/npm/letsencrypt
mkdir -p data/jellyfin/config
mkdir -p data/jellyfin/cache
mkdir -p data/portainer
mkdir -p data/uptime-kuma
mkdir -p data/speedtest-tracker
mkdir -p data/romm/resources
mkdir -p data/romm/redis-data
mkdir -p data/romm/assets
mkdir -p data/romm/config
mkdir -p data/romm/db

# 4. Crear carpetas de medios predeterminadas si no existen
echo "🎬 Verificando carpetas de medios..."
mkdir -p "$HOME/media/tvshows"
mkdir -p "$HOME/media/peliculas"
mkdir -p "$HOME/media/roms"

echo ""
echo "🎉 ¡Inicialización completada con éxito!"
echo "Comandos para iniciar:"
echo "  1. nano .env               # Revisa tus contraseñas"
echo "  2. docker compose up -d    # Levanta todos los servicios"
echo "  3. docker compose ps       # Comprueba el estado"
