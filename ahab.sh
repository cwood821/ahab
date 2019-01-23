#!/bin/sh

start_docker_if_not_running() {
    echo "Will start docker if not already running..."
    if (! docker stats --no-stream ); then
        # Open docker on Mac 
        open /Applications/Docker.app
        # Loop until docker is running
        while (! docker stats --no-stream ); do
            echo "Waiting for Docker to launch..."
            sleep 2
        done
    fi
}

if [ "$1" = "list" ] || [ "$1" = "ls" ]; then
    cat ahab-commands.txt
fi

if [ "$1" = "art" ] || [ "$1" = "artisan" ]; then
    shift
    docker-compose exec app php artisan $*
fi

if [ "$1" = "start" ] || [ "$1" = "up" ]; then
    shift
    start_docker_if_not_running
    docker-compose up -d $*
    # Check if sql lite database exists; if not, create it
    if [ ! -f ./application/database/testing.sqlite ]; then 
        touch ./application/database/testing.sqlite 
    fi
    # Since we are restarting, blow away all the uploads
    rm -rf ./application/storage/app/photos/*
    # Install composer
    docker-compose exec app composer install
    # Run migrations for application and test databases
    # TODO: add some sort of check for mysql to have finished booting
    docker-compose exec app php artisan migrate:fresh --seed
    docker-compose exec app php artisan migrate:fresh --database="testing"
    # Run NPM installations, compile assets
    docker-compose run --rm node npm install
    docker-compose run --rm node npm audit fix
    docker-compose run --rm node npm run dev
fi

if [ "$1" = "stop" ] || [ "$1" = "down" ]; then
    shift
    docker-compose down $*
fi

if [ "$1" = "ssh" ] || [ "$1" = "bash" ]; then
    shift
    docker-compose exec app bash
fi 

if [ "$1" = "composer" ] || [ "$1" = "c" ]; then
    shift
    docker-compose exec app composer $*
fi

if [ "$1" = "dusk" ] || [ "$1" = "c" ]; then
    shift
    docker-compose exec app php artisan dusk
fi

if [[ "$1" = "test" ]] || [[ "$1" = "phpunit" ]]; then
    shift
    docker-compose exec app vendor/bin/phpunit $* --testdox tests
fi

if [[ "$1" = "npm" ]] || [[ "$1" = "n" ]]; then
    shift
    docker-compose run --rm node npm $* 
fi

if [[ "$1" = "sass" ]] || [[ "$1" = "compile" ]]; then
    shift
    docker-compose run --rm node npm run dev
fi

if [[ "$1" = "fresh" ]] || [[ "$1" = "f" ]]; then
    shift
    # Delete any uploaded photos
    rm -rf ./application/storage/app/photos/*
    docker-compose exec app composer dump-autoload
    # Run migrations for application and test databases
    docker-compose exec app php artisan migrate:fresh --seed
    docker-compose exec app php artisan migrate:fresh --database="testing"
    docker-compose exec app php artisan cache:clear
fi

if [[ "$1" = "seed" ]] || [[ "$1" = "refresh-db" ]]; then
    shift
    docker-compose exec app php artisan migrate:fresh --seed
    docker-compose exec app php artisan migrate:fresh --database="testing"
fi

if [[ "$1" = "clean" ]]; then
    docker system prune --all --force --volumes
fi

if [[ "$1" = "logs" ]] || [[ "$1" = "l" ]]; then
    shift
    docker-compose logs app | less
fi

if [[ "$1" = "watch" ]]; then
    docker-compose run --rm node npm run watch
fi
