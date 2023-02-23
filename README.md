# Platform Engineering Library

A compendium of ways

## Requirements

* [tanka]("https://tanka.dev/")
* [kubectl]("https://kubernetes.io/docs/tasks/tools/")
* [jb]("https://github.com/jsonnet-bundler/jsonnet-bundler")

## To install

1. Verify that `tanka`, `kubectl`, `jb` are installed. 

2. Run the init.sh script

```
./init.sh
```

## To run the tests

```
docker-compose run --rm app bundle exec rspec
```
