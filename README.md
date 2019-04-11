# file-manager-sample

Ruby on Rails(API) + Nuxt.js/Vue.js(FRONT)を使用したファイル管理のサンプルです。

## 使用言語・ライブラリ

- Server side
  - Ruby on Rails
- Front end
  - Vue.js
  - Nuxt.js
  - Vuetify

## 環境構築アプリケーション

- Docker
- Docker Compose
- direnv
- git

## セットアップ

```shell
$ git clone git@github.com:greendrop/file-manager-sample.git
$ cd file-manager-sample
$ vi .envrc
$ direnv allow
$ docker-compose pull
$ docker-compose build
$ docker-compose run --rm server-web bash
$ cp config/application.yml.example config/application.yml
$ cp config/database.yml.example config/database.yml
$ bundle install
$ yarn install
$ rake db:create
$ docker-compose run --rm front bash
$ cp .env.example .env
$ yarn install
$ exit
$ docker-compose up
```

### .envrc

```
export USER_ID=`id -u`
export GROUP_ID=`id -g`
```