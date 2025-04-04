#!/bin/bash

# 🧠 Usa "dev" por defecto si no se especifica entorno
ENVIRONMENT=${1:-dev}
SERVICE=${2:-all}

# 🪓 Verifica existencia de los archivos de entorno
REQUIRED_ENVS=(.env.common .env.secrets .env.${ENVIRONMENT})
for file in "${REQUIRED_ENVS[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ Falta el archivo de entorno requerido: $file"
    exit 1
  fi
done

# 🔇 Colores para los logs porque somos profesionales (y dramáticos)
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🧼 Bajando contenedores anteriores...${NC}"
docker compose --env-file .env.common --env-file .env.secrets --env-file .env.${ENVIRONMENT} down --volumes --remove-orphans

echo -e "${CYAN}🧹 Limpiando imágenes sin uso...${NC}"
docker image prune -f

echo -e "${GREEN}🚀 Levantando servicios (${SERVICE}) en entorno (${ENVIRONMENT})...${NC}"

if [ "$SERVICE" = "all" ]; then
  docker compose --env-file .env.common --env-file .env.secrets --env-file .env.${ENVIRONMENT} up --build
else
  # Soporte para archivo de variables por servicio
  SERVICE_ENV=.env.${SERVICE}
  if [ -f "$SERVICE_ENV" ]; then
    docker compose --env-file .env.common --env-file .env.secrets --env-file "$SERVICE_ENV" up --build "$SERVICE"
  else
    echo -e "${CYAN}⚠️ Nota:${NC} No se encontró archivo ${SERVICE_ENV}, levantando con comunes y secretos."
    docker compose --env-file .env.common --env-file .env.secrets up --build "$SERVICE"
  fi
fi