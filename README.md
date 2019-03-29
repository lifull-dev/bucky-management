# README

## Development

### Cleanup

```bash
rm -rf docker/mysql/volumes/ # all remove data in mysql
docker volume prune
docker image prune -a
```

### Main

```bash
# build and start
docker-compose -f docker-compose.dev.yml up --build -d
# execute command in container
docker exec -it bm-app rails db:create
docker exec -it bm-app rails db:migrate
docker exec -it bm-app rails db:fixtures:load # insert testing data

docker exec -it bm-app rails db:fixtures:load FIXTURES=test_suites,test_cases,jobs # only specified table

# shutdown
docker-compose -f docker-compose.dev.yml down
```

open <http://localhost>

## Production

```bash
docker-compose up -d
docker-compose run --rm web rake db:create db:migrate
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

### Dockerfile

**- Dockerfile:** For the production environment

**- Dockerfile.dev:** For the development environment