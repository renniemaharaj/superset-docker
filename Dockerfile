######################################################################
# Superset 5 production Dockerfile with pinned flask-limiter
######################################################################
FROM python:3.11-slim-bookworm AS superset

ENV SUPERSET_ENV=production \
    FLASK_ENV=production \
    DEV_MODE=false \
    SUPERSET_PORT=8088 \
    SUPERSET_HOME=/app/superset_home \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system deps (following superset guide + extras)
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    libpq-dev \
    libjpeg-dev \
    libsasl2-dev \
    libldap2-dev \
    default-libmysqlclient-dev \
    curl \
    unzip \
    git \
    nginx \
    python3.11-dev \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip & tooling
RUN pip install --upgrade pip setuptools wheel

# Core stable deps
RUN pip install --no-cache-dir \
    "numpy<2.0.0" \
    "pandas<2.2.0"

# Superset 5 + gunicorn + pinned flask-limiter
RUN pip install --no-cache-dir \
    apache-superset==5.0.0 \
    gunicorn \
    flask-limiter==3.5.1 \
    marshmallow==3.19.0

# Extra drivers
RUN pip install --no-cache-dir \
    'google-cloud-bigquery[bqstorage,pandas]' \
    psycopg2-binary

# Create superset user & home directory
RUN adduser --disabled-password --gecos '' superset \
    && mkdir -p ${SUPERSET_HOME} \
    && chown superset:superset ${SUPERSET_HOME}

# Copy entrypoint & config
COPY entrypoint.sh /app/entrypoint.sh
COPY superset_cfx.py /app/superset_cfx.py
RUN chmod +x /app/entrypoint.sh

USER superset
WORKDIR /app

EXPOSE ${SUPERSET_PORT} 80
