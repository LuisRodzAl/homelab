# 🏠 Mi Homelab — Infraestructura como Código

Repositorio para la orquestación, despliegue y mantenimiento automatizado de servicios locales sobre Ubuntu Server y Docker Compose.

---

## 📦 Stack de Servicios

| Servicio | Imagen | Puerto / URL Local | Descripción |
| :--- | :--- | :--- | :--- |
| **Pi-hole** | `pihole/pihole` | `http://pihole.casa` (`:8081/admin`) | Bloqueador de anuncios a nivel de red y servidor DNS local (puerto 53). |
| **Nginx Proxy Manager** | `jc21/nginx-proxy-manager` | `http://192.168.1.68:8181` (`:80`, `:443`) | Reverse Proxy con UI web y gestión automática de certificados SSL. |
| **Jellyfin** | `jellyfin/jellyfin` | `http://jellyfin.casa` (`:8096`) | Servidor multimedia privado de streaming de películas y series. |
| **Portainer** | `portainer/portainer-ce` | `http://portainer.casa` (`:9000`) | Panel de control visual para contenedores, volúmenes e imágenes Docker. |
| **Uptime Kuma** | `louislam/uptime-kuma` | `http://uptime.casa` (`:3001`) | Monitor de salud, estado y alertas en tiempo real de servicios y webs. |
| **RomM** | `rommapp/romm` + `mariadb:11` | `http://romm.casa` (`:8766`) | Gestor de bibliotecas de videojuegos retro y emulación en el navegador. |
| **Speedtest Tracker** | `linuxserver/speedtest-tracker` | `http://speedtest.casa` (`:8765`) | Métricas y gráficos periódicos de velocidad y latencia de conexión a internet. |

---

## 🌐 Ecosistema Local (.casa)

El stack utiliza **Pi-hole** como resolver DNS local y **Nginx Proxy Manager** como proxy reverso:
1. En Pi-hole se apuntan los dominios `*.casa` a la IP local del servidor (`192.168.1.68`).
2. Nginx Proxy Manager recibe el tráfico HTTP/HTTPS en el puerto 80/443 y lo redirige internamente al contenedor y puerto correspondiente sin exponer puertos externos adicionales.

---

## 🤖 Automantenimiento y CI/CD

El repositorio está diseñado para mantenerse actualizado y seguro con mínima fricción:
* **Dependabot:** Monitorea semanalmente las imágenes de Docker Compose en este repositorio y genera Pull Requests cuando hay nuevas versiones o parches de seguridad disponibles.
* **GitHub Actions:** Valida automáticamente la sintaxis y coherencia de `docker-compose.yml` en cada push o Pull Request de Dependabot antes de fusionarlo.
* **Watchtower:** Ejecuta en el servidor inspecciones periódicas contra los registros de contenedores (Docker Hub y GitHub Container Registry) y actualiza los contenedores en caliente sin caída perceptible del servicio.

---

## 🚀 Despliegue en un Nuevo Entorno

Para replicar este homelab en otro servidor o máquina limpia:

### 1. Clonar el repositorio
```bash
git clone https://github.com/LuisRodzAl/homelab.git
cd homelab
```

### 2. Inicializar carpetas y entorno
Ejecuta el script de inicialización automática:
```bash
chmod +x init.sh
./init.sh
```

### 3. Configurar variables de entorno
Edita el archivo `.env` generado y define tus contraseñas y claves de API:
```bash
nano .env
```

### 4. Levantar el stack
```bash
docker compose up -d
```

---

## 🛠️ Comandos de Administración Útiles

```bash
# Ver estado de los contenedores
docker compose ps

# Ver logs en tiempo real (ej. Jellyfin)
docker compose logs -f jellyfin

# Reiniciar un servicio tras cambios
docker compose restart npm

# Actualizar manualmente todas las imágenes y recrear contenedores
docker compose pull && docker compose up -d

# Detener todos los servicios (sin perder datos)
docker compose down
```

---

## 🔒 Seguridad y Buenas Prácticas
* **Nunca comitear `.env`:** Todas las contraseñas, tokens y claves de API deben residir en `.env` (ignorado por `.gitignore`).
* **Datos persistentes:** Toda la información de bases de datos y configuraciones se almacena en `./data/`, la cual está excluida del control de versiones.
