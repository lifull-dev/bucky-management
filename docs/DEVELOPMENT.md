# Development Guide

## Overview
This guide provides detailed instructions for setting up and running Bucky-Management in a development environment.

## Prerequisites
- Docker Desktop
- Docker Compose v2
- macOS (Intel or Apple Silicon)

## Architecture Changes

### Ruby & Dependencies
- **Ruby**: 3.0.0 → 3.0.7 (Debian Bullseye, EOL対応)
- **Bundler**: 2.2.33 (Gemfile.lock互換性)
- **MySQL**: 5.7.39 (Intel) / 8.0 (Apple Silicon)

### Platform Support
- **Intel Mac**: Uses `docker-compose.with_mysql.yml` (MySQL 5.7.39)
- **Apple Silicon Mac**: Uses `docker-compose.with_mysql.arm.yml` (MySQL 8.0)

## Setup Instructions

### 1. Environment Variables

Create `.env.development` (if not exists):
```bash
TZ=Asia/Tokyo
RAILS_ENV=development
BUCKY_DB_NAME=bucky_development
BUCKY_DB_USERNAME=root
BUCKY_DB_PASSWORD=password
BUCKY_DB_HOSTNAME=db
SECRET_KEY_BASE=development_secret_key_base_dummy_value_for_local_development_only
```

Load environment variables:
```bash
export $(cat .env.development | xargs)
```

### 2. Start Containers

**Apple Silicon Mac:**
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml up -d
```

**Intel Mac:**
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.yml up -d
```

### 3. Initialize Database (First Time Only)

```bash
docker exec -it bm-app rails db:create
docker exec -it bm-app rails db:migrate
```

### 4. Access Application

- Development: http://localhost:3000
- Production: http://localhost (via nginx)

## Container Management

### Stop Containers
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml down
```

### Remove All Data (including database)
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml down -v
```

### View Logs
```bash
# All containers
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml logs

# Specific container
docker logs bm-app
docker logs bm-mysql
docker logs bm-web
```

### Check Container Status
```bash
docker ps -a | grep bm-
```

## Troubleshooting

### Containers Won't Start

1. Remove existing containers and volumes:
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml down -v
```

2. Rebuild images:
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml up -d --build
```

### Permission Errors

If you encounter permission errors with MySQL volumes:
```bash
rm -rf docker/mysql/volumes
mkdir -p docker/mysql/volumes
```

### Gem Installation Issues

The `dev-entrypoint.sh` script automatically runs `bundle install` on container startup. If gems are missing:
```bash
docker exec -it bm-app bundle install
docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.with_mysql.arm.yml restart app
```

## Technical Details

### Development Environment Features

1. **Automatic Gem Installation** (`dev-entrypoint.sh`)
   - Runs `bundle install` on startup
   - Waits for MySQL to be ready
   - Prevents race conditions

2. **Volume Mounts**
   - `.:/app` - Live code reloading
   - `bundle_cache:/usr/local/bundle` - Gem caching for faster startup

3. **Port Mapping**
   - Port 3000 exposed for direct access
   - Development uses TCP instead of Unix socket

### File Structure

```
docker-compose.yml              # Base configuration
docker-compose.dev.yml          # Development overrides
docker-compose.with_mysql.yml   # MySQL 5.7 (Intel)
docker-compose.with_mysql.arm.yml # MySQL 8.0 (ARM)
dev-entrypoint.sh               # Development startup script
.env.development                # Development environment variables
```

### Key Differences: Intel vs ARM

| Component | Intel Mac | Apple Silicon Mac |
|-----------|-----------|-------------------|
| MySQL Version | 5.7.39 | 8.0 |
| Platform | linux/amd64 | linux/arm64 |
| Compose File | with_mysql.yml | with_mysql.arm.yml |
| Collation | utf8mb4_general_ci | utf8mb4_0900_ai_ci |

### MySQL 8.0 Changes (ARM)

- Default collation: `utf8mb4_0900_ai_ci`
- Authentication: `mysql_native_password`
- Named volumes for better permission handling

## Production Considerations

### Environment Variables
Production requires proper configuration:
```bash
export BUCKY_DB_NAME=bucky_production
export BUCKY_DB_USERNAME=your_username
export BUCKY_DB_PASSWORD=your_password
export BUCKY_DB_HOSTNAME=your_db_host
export SECRET_KEY_BASE=$(docker exec -it bm-app rake secret)
```

### Differences from Development
- Uses Unix socket instead of TCP port
- No volume mounts (code baked into image)
- Nginx proxy on port 80
- No automatic gem installation

## CI/CD

### CircleCI Configuration
- Ruby 3.0.7 image: `cimg/ruby:3.0.7-node`
- Bundler config: `bundle config set --local path 'vendor/bundle'`
- Cache key: `Gemfile.lock` checksum

### RuboCop
- Plugin format: `plugins: - rubocop-rails`
- Auto-enable new cops: `NewCops: enable`
- Department prefixes required (e.g., `Style/Documentation`)

## Additional Resources

- [Bucky-core](https://github.com/lifull-dev/bucky-core) - Test execution framework
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Rails 7.0 Documentation](https://guides.rubyonrails.org/v7.0/)
