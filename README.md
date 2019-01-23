# Ahab 

| Slay the complexity of the dreaded whale! Or, just feel free to forget all those docker commands.

A commander to slay the complexity of the dreaded whale! In other words, a  shell script to wrap common docker commands in your Laravel project. 

Its aim is to serve as a robust boilerplate for Docker-based project helper scripts. If ye seek something more robust, consider [Vessel](https://github.com/shipping-docker/vessel).

## Usage

```
./ahab.sh start
```

### Why this thing?
At its core, Ahab abstracts away the verbose docker commands you might use often in development. It does this via a single shell script, which is easily modified to suit your preferences.

Instead of running:
```
docker-compose exec app php artisan migrate:fresh --seed
```

Just run:
```
./ahab.sh seed
```

## Credits

Ahab originated while watching [Docker in Dev](https://serversforhackers.com/s/docker-in-dev-v2-i) and evolved in subsequent Laravel projects.
