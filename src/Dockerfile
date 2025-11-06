FROM n8nio/n8n:latest

# Instalar dependências necessárias para gráficos
USER root

# Support both Alpine (apk) and Debian/Ubuntu (apt-get) based images.
RUN set -eux; \
    if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache \
            build-base \
            cairo-dev \
            pango-dev \
            libjpeg-turbo-dev \
            giflib-dev \
            librsvg; \
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y --no-install-recommends \
            build-essential \
            libcairo2-dev \
            libpango1.0-dev \
            libjpeg-dev \
            libgif-dev \
            librsvg2-dev && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "No known package manager found (apk or apt-get)." >&2; exit 1; \
    fi

# Install the JS charting library into an isolated directory so it doesn't interact
# with n8n's workspace-style package.json. We set NODE_PATH so Node can find it at runtime.
RUN set -eux; \
    mkdir -p /opt/n8n-extras; \
    cd /opt/n8n-extras; \
    # create minimal package.json so npm install works in this dir
    npm init -y >/dev/null 2>&1 || true; \
    # install chartjs-node-canvas here; try a specific major then fallback to default
    npm install --no-audit --no-fund chartjs-node-canvas@^4 || npm install --no-audit --no-fund chartjs-node-canvas; \
    npm install --no-audit --no-fund \
        simple-statistics \
        jstat \
        mathjs \
        @stdlib/stats-kruskal-test; \
    rm -rf /root/.npm /root/.cache

# Ensure Node can resolve modules from /opt/n8n-extras
# Use parameter expansion with default to avoid undefined-variable warnings in linters
ENV NODE_PATH=/opt/n8n-extras/node_modules:${NODE_PATH:-}

USER node
