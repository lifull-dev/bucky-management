# README

## Overview
Bucky-management is a web application that shows test result executed by Bucky-core.

## Getting Started
We prepare two docker-compose files to start up Bucky-managemnt.
- **docker-compose.yml**: Using DB container in docker-compose.yml
- **docker-compose.without_db.yml**: Using external DB

### Set environment variables
- You should set RAILS_ENV, because it doesn't set in default
- Use default value if starting by docker-compose.yml
```bash
export RAILS_ENV=${RAILS_ENV} # e.g. production, development, test
export BUCKY_DB_USERNAME=${BUCKY_DB_USERNAME} # default: root
export BUCKY_DB_PASSWORD=${BUCKY_DB_PASSWORD} # default: password
export BUCKY_DB_HOSTNAME=${BUCKY_DB_HOSTNAME} # default: db
```

### Build and start Bucky-management
```bash
# Use DB container
docker-compose up --build -d
# Use external DB
docker-compose -f docker-compose.without_db.yml up --build -d
```
### Migration database and table
```bash
# Only at first time not created DB yet.
docker exec -it bm-app rails db:create
# Do this if new migration file is added.
docker exec -it bm-app rails db:migrate
```
### Publish secret key base
```bash
docker exec -it bm-app rake secret
```

### Set secret key base to environment variables
You should restart Bucky-management after you export secret key base.
```bash
export SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Restart Bucky-management
docker-compose up --build -d
```

### Check your Bucky-management dashboard
http://localhost