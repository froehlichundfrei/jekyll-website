# About this Repo

This is the Fröhlich und Frei Docker Image for jekyll based website development. You can find the can use the automated build version from [Docker Hub](https://hub.docker.com/r/froehlichundfrei/jekyll-website/).

It is based on the official docker images for [ruby 2.3](https://github.com/docker-library/ruby/blob/master/2.3/Dockerfile) and [node 4.2.6](https://github.com/nodejs/docker-node/blob/master/4.2/Dockerfile).

## What else is included:

### Packages:

* python-pygments
* make
* openjdk-7-jre

### Ruby Gems

* jekyll, jekyll-picture-tag, jekyll-watch, jekyll-paginate
* redcarpet
* pygments.rb
* s3_website

### Node Modules

* bower
* gulp


## Makefile

```
# delete all docker images
make clean

# build docker image
make build

# run docker image
make run
```
