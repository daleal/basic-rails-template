# Basic Rails Template

Basic Rails 6 template with academic purposes built with `Docker` and `docker-compose` to **_plug and play_**. For a more advanced template (_docker-wise_) visit [this repo](https://github.com/daleal/rails-template).

## Running Locally

### Requirements

The requirements for this template are simple:

* `Docker`
* `Docker Compose`

Additionally, to deploy to `heroku` you will need:

* `Heroku`

### Plug and Play

This repo comes with a `docker-compose.yml` file to handle using a `postgres` image pulled from the web and to use a `.env` file for environmental variables. As such, `compose` requires a `.env` file to function, so run:

```sh
cp .env.example .env
```

After that, configure the `.env` file as you please and `compose` is now ready to be used.

To get `on rails` quickly, build the image:

```sh
docker-compose build
```

Then, create the database:

```sh
docker-compose run web rails db:create
```

Finally, start the server:

```sh
docker-compose up
```

From now on, every command regarding the app that should be run as `[COMMAND]` will now be run as `docker-compose run web [COMMAND]`. This includes database migrations (`docker-compose run web rails db:migrate`).

### Caveats (or, may I say, Docker and Windows)

If you are using `Docker` on _Linux_ or `Docker` on _MacOS_, chances are your usage process has been almost flawless, and the instructions given in the tutorial worked at the first try. However, if you are using `Docker Toolbox` on Windows or `Docker for Windows` on Windows, things are different. Mainly, two things change:

* Due to the technology being run inside a _Virtual Machine_, instead of finding your app in `localhost:3000`, your app will be defaulted to `192.168.99.100:3000` and will **not** be found in `localhost:3000`.
* Due to the database volume being mounted to a _named volume_ created by the _Virtual Machine_, every Docker update **will** wipe your database clean. When using for development purposes, some simple seeds are enough to make this a _no-problem_. Keep an eye if that is your production environment, though, as data **will** be lost if you are not careful.

### Docker Image

The image generated by `docker-compose build` with the original repo contains a standard Rails 6 app using `postgresql` as the database, `sass` as the stylesheet pre-processor and `puma` as the webserver.

### When to Build

The command `docker-compose build` must be used only in 2 cases:

1. Changes in the `Gemfile`: `docker-compose build` will notice if either the `Gemfile` or the `Gemfile.lock` present any changes. If so, it will re-run `bundle install` to update the image (this **will** take a while, so go make yourself a coffee. Also, _try_ to change the `Gemfile` as little as possible if you value your time at all)
2. New `assets`: `docker-compose build` will notice if new assets need to be precompiled and will run `bundle exec rails assets:precompile` to update the image

Notice that `Docker` is smart and if you run `docker-compose build` and the `Gemfile` has not changed and no new `assets` need to be precompiled, `Docker` will use cached layers to build the image, dramatically decreasing the amount of time wasted in your life (hopefully).

## Heroku Deployment

To deploy to `heroku` using Container Registry, make sure to be logged in to the platform (`heroku login`). Then, log in to Container Registry:

```sh
heroku container:login
```

After that, create a new `heroku` app:

```sh
heroku create
```

Don't forget to add the `heroku-postgresql` addon to your `heroku` app (when deploying to `heroku`, only the Rails app will be deployed, and the `postgres` container used locally must be replaced with the `heroku-postgresql` addon):

```sh
heroku addons:create heroku-postgresql:hobby-dev
```

This command will add the **free** basic `heroku-postgresql` addon to your app (you can upgrade this later if you desire).

Next, build the image and push it to Container Registry:

```sh
heroku container:push web
```

Finally, release the image to your app:

```sh
heroku container:release web
```

**Important Note**: Once your app is created, to push new changes you only have to run `heroku container:push web` and then `heroku container:release web`.

To open the app in a browser, you can run `heroku open`. You can also access directly using the app's URL.
