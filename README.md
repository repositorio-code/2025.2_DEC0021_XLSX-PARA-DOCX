# n8n local runner

This folder contains a small helper to build and run a local n8n Docker container with persistent data.

Files:
- `Dockerfile` - image additions for charting libs
- `run.sh` - enhanced runner (builds image if missing, loads .env, sets up persistent storage)
- `.env` (optional) - place next to `run.sh` to configure runtime options

Recommended `.env` example:

```
# Use a named volume for persistence (optional). If unset, runner will create ./n8n-data
N8N_VOLUME_NAME=n8n-data

# Host port for n8n
PORT=5678

# Database settings (sqlite by default)
DB_TYPE=sqlite
DB_SQLITE_FILE=/home/node/.n8n/database.sqlite
```

Usage:

From this directory run:

```bash
./run.sh
```

What the script does:
- Builds the Docker image `n8n-custom:local` from `Dockerfile` if it doesn't exist
- Loads environment variables from `.env` (if present) and passes them to the container
- Creates/uses a named Docker volume `N8N_VOLUME_NAME` or falls back to `./n8n-data`
- Starts the container `n8n-custom` and maps the configured port

Notes:
- For production use prefer a named Docker volume and a proper DB (MySQL/Postgres).
- The Dockerfile runs `npm install chartjs-node-canvas` to enable server-side chart rendering.
