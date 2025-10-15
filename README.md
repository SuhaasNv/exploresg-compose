# ExploreSG — Docker Compose (prebuilt images)

This repository runs the ExploreSG platform using prebuilt Docker images from `sreerajrone/*`. It contains only orchestration (no application source code).

## Prerequisites
- Docker Desktop (macOS/Windows/Linux)
- macOS Apple Silicon note: images are amd64; the compose file pins `platform: linux/amd64` for compatibility.

## Services
- Frontend (3000) → `sreerajrone/exploresg-frontend-service:latest`
- Auth (8081) → `sreerajrone/exploresg-auth-service:latest`
- Fleet (8082) → `sreerajrone/exploresg-fleet-service:latest`
- Booking (8083) → `sreerajrone/exploresg-booking-service:latest`
- Payment (8084) → `sreerajrone/exploresg-payment-service:latest`
- Postgres (5432)

Note: Notification is intentionally omitted until the image is published.

## Quick Start
```bash
# 1) Configure environment
cp .env.example .env
# Edit .env and set:
# - GOOGLE_CLIENT_ID (Google OAuth Web Client ID)
# - MAPBOX_TOKEN (public Mapbox token)
# - JWT_SECRET_KEY (base64 secret: `openssl rand -base64 32`)

# 2) Pull images and start
docker compose pull
docker compose up -d

# 3) Verify services
docker compose ps
open http://localhost:3000
```

## Google OAuth Settings
In Google Cloud Console → APIs & Services → Credentials → your Web Client:
- Authorized JavaScript origins:
  - `http://localhost:3000`
- Authorized redirect URIs:
  - `http://localhost:8081/login/oauth2/code/google`

The frontend `GOOGLE_CLIENT_ID` MUST equal backend `OAUTH2_JWT_AUDIENCES`.

## Environment Variables
See `.env.example` for the full list. Key groups:
- Frontend: `API_BASE_URL`, `FLEET_API_BASE_URL`, `GOOGLE_CLIENT_ID`, `MAPBOX_TOKEN`, `APP_ENV`, `DEBUG`
- Auth: `JWT_SECRET_KEY`, `OAUTH2_JWT_AUDIENCES`, `OAUTH2_JWT_ISSUER_URI`, `CORS_ALLOWED_ORIGINS`
- Shared DB: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `SPRING_DATASOURCE_*`

## Common Commands
```bash
# View logs
docker compose logs -f auth
docker compose logs -f frontend

# Stop stack
docker compose down

# Reset DB data (optional)
docker compose down
docker volume rm exploresg-compose_pgdata  # adjust volume name if different
```

## Troubleshooting
- Manifest error on Apple Silicon:
  - Compose sets `platform: linux/amd64`. Ensure Docker Desktop is running, then `docker compose pull`.
- “Failed to authenticate” on first try:
  - Wait 30–60s after first start (initial warm-up), then retry.
  - Verify Google OAuth console settings and `.env` values.
- Frontend env.js generation:
  - The image writes runtime env to `env.js`. Ensure the container is running and refresh the browser.

## Notes
- Data persists via the `pgdata` Docker volume.
- When `sreerajrone/exploresg-notification-service` is published, add it to `compose.yaml` similar to other services and expose `8085:8082`.
