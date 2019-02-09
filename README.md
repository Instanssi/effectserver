# Effect Server for Instanssi Party

UDP and WebSocket packet abstraction for multiple DMX controllers.

## Installing

First, get Node.js and npm. On Debian and related distros you most likely
want the `nodejs-legacy` and `npm` packages.

Fetch the server's dependencies using npm.

	npm install

## Configuring

`config.cson` contains the last config from Instanssi 2012. If you want to
test your light effects without an actual Enttec device, leave the host path
unconfigured.

## Running

    npm start

