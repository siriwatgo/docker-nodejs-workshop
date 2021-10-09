## Documentation

This will configure nginx not send any version numbers in the HTTP header: https://github.com/openresty/headers-more-nginx-module

Other solution related to removing ngix HTTP header: http://wiki.nginx.org/HttpHeadersMoreModule

Implement a limit on how often a client can call the API within a defined timeframe: https://www.npmjs.com/package/express-rate-limit

Rate Limiting: https://www.ibm.com/docs/en/sva/9.0.6?topic=configuration-rate-limiting

### Requirements

Make sure you have installed `docker` and `docker-compose`. Both are easily installed via:

Docker: https://docs.docker.com/engine/installation/

Docker compose: https://docs.docker.com/compose/install/

### Launching containers

You can specify the configuration file with the `-f` flag, which will result in:

    docker-compose -f docker-compose.yml up --build -d

OR

    docker-compose up --build -d

You can use your browser to access the with URL:

    http://localhost/
