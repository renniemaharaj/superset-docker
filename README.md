# Superset Docker Deployment

This is a **custom Superset Docker deployment** for production environments.

## Overview

This deployment is built on a Python Docker base image, following Superset's official bare-bones Python installation guide. Superset and its dependencies are installed within this container.

Key features:

* **Persistent storage**: PostgreSQL data is mounted to the host for data persistence.
* **BigQuery support**: Includes GCP key mounting for BigQuery integrations.
* **Production-ready**: Uses Gunicorn with gthreads to run Superset.
* **Nginx proxy**: Serves Superset through Nginx for added performance and security.
* **Flexible configuration**: Can be configured via `.env` or a custom `superset_cfx.py` file.

This setup provides a lean, production-targeted Superset deployment.

## Deployment Structure

### Docker Compose Files

* **Lean Deployment**: `docker-compose.yml`

  * Runs the Superset app without Celery worker and beat.
  * Suitable for lightweight, production-ready deployments.

* **Extended Deployment**: `docker-compose-extended.yml`

  * Includes Superset app, Celery worker, and beat.
  * Suitable for large-scale deployments requiring asynchronous processing.

### Volumes

* `superset_home`: Superset configuration and data.
* `pgdata`: Persistent PostgreSQL database storage.
* `redis_data`: Persistent Redis cache storage.

## Configuration

### Environment Variables

Superset configuration can be set in the `.env` file:

Example `.env`:

```env
SUPERSET_ENV=production
FLASK_ENV=production
DEV_MODE=false
SUPERSET_PORT=8088
DATABASE_DIALECT=postgresql
DATABASE_DB=superset
DATABASE_HOST=db
DATABASE_PORT=5432
DATABASE_USER=superset
DATABASE_PASSWORD=superset
POSTGRES_DB=superset
POSTGRES_USER=superset
POSTGRES_PASSWORD=superset
REDIS_HOST=redis
REDIS_PORT=6379
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0
SUPERSET_ADMIN_USERNAME=admin
SUPERSET_ADMIN_PASSWORD=admin
GOOGLE_APPLICATION_CREDENTIALS=/app/config/gcp-key.json
```

### Superset Config File

For advanced configuration, use `superset_cfx.py`. This allows you to customize settings beyond `.env` variables, including:

* SECRET_KEY
* Rate limiting backend
* Cache configuration
* Additional Superset options

Example:

```python
SECRET_KEY = "YOUR_RANDOM_SECRET_KEY"
```

## Dockerfile

The Dockerfile is designed to be easily extensible:

* Core dependencies and Superset installation are separated from extra packages.
* Allows modification without rebuilding the entire image.

You can add or modify system dependencies, Python packages, or Superset extensions.

## Nginx

Nginx is used as a reverse proxy to serve the Superset application. Configuration can be found in:

```
nginx/nginx.conf
nginx/templates/
```

## Commands

Build and run the lean deployment:

```bash
docker-compose -f docker-compose.yml up -d --build
```

Build and run the extended deployment:

```bash
docker-compose -f docker-compose-extended.yml up -d --build
```

## Notes

* Ensure `.env` and `superset_cfx.py` are configured before starting.
* Superset data and configurations are persisted in volumes for safety.
* The GCP key for BigQuery integration must be placed at `/app/config/gcp-key.json`.

---

This setup offers a scalable, production-ready Superset deployment with flexibility for extension and configuration.
