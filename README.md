# Bucky-Management
![logo](docs/assets/Bucky-Management.png)
[![Maintainability](https://api.codeclimate.com/v1/badges/aaeb28e229926007442b/maintainability)](https://codeclimate.com/github/lifull-dev/bucky-management/maintainability)

## Overview
Bucky-management is a web application that shows test results executed by [Bucky-core](https://github.com/lifull-dev/bucky-core).

## Quick Start

### Development Environment

**Apple Silicon Mac (M1/M2/M3):**
```bash
export $(cat .env.development | xargs)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml up -d
docker exec -it bm-app rails db:create db:migrate
```
Access: http://localhost:3000

**Intel Mac:**
```bash
export $(cat .env.development | xargs)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.yml up -d
docker exec -it bm-app rails db:create db:migrate
```
Access: http://localhost:3000

### Production Environment

```bash
# Set environment variables
export BUCKY_DB_NAME=bucky_production
export BUCKY_DB_USERNAME=your_username
export BUCKY_DB_PASSWORD=your_password
export BUCKY_DB_HOSTNAME=your_db_host
export SECRET_KEY_BASE=$(docker exec -it bm-app rake secret)

# Start with external DB
docker-compose up --build -d

# Or start with MySQL container (Intel Mac)
docker-compose -f docker-compose.yml -f docker-compose.with_mysql.yml up --build -d

# Initialize database
docker exec -it bm-app rails db:create db:migrate
```
Access: http://localhost

## Documentation

- [Development Guide](docs/DEVELOPMENT.md) - Detailed setup, troubleshooting, and technical details

## Requirements

- Docker Desktop
- Docker Compose v2
