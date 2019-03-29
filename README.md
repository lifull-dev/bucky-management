# README

## Start up

```bash
# Set environmet variables
export RAILS_ENV=${RAILS_ENV} # e.g. production, development, test
export SECRET_KEY_BASE=${SECRET_KEY_BASE}
export BUCKY_DB_USERNAME=${BUCKY_DB_USERNAME} # default: root
export BUCKY_DB_PASSWORD=${BUCKY_DB_PASSWORD} # default: password
export BUCKY_DB_HOSTNAME=${BUCKY_DB_HOSTNAME} # default: db

# build and start
docker-compose up --build -d
# execute command in container
docker exec -it bm-app rails db:create
docker exec -it bm-app rails db:migrate

# shutdown
docker-compose down
```

open <http://localhost>

## Cleanup DB data

```bash
rm -rf docker/mysql/volumes/ # all remove data in mysql
docker volume prune
docker image prune -a
```


## Publish secret key base

```bash
docker-compose run --rm web rake secret
```

## Note

### routing

* <http://localhost:/rails/info/routes>

### remove container & image

```bash
docker rm `docker ps -a -q`
docker ps -aq -f "status=exited" | xargs docker rm -v && docker images -q -f "dangling=true" | xargs docker rmi && docker volume ls -qf dangling=true | xargs docker volume rm
```
