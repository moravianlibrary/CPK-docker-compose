## What is this about?

This project enables anyone familiar with [vufind](https://github.com/vufind-org/vufind) easily deploy his application using a Docker container.

It is based on Debian "jessie", with php7.1 taken from [here](https://hub.docker.com/_/php/). Concrete image is called `php7.1-apache-jessie`.

### How does it work?

It is divided into three minor Docker containers, where one inherits from the other. You can see them in the `builds` directory.

On the top is the so called `cpk` container, which stands for `Centrální portál knihoven` alias `The Czechian Central Library Portal` to let everyone know about the origin of this project. That is https://www.knihovny.cz/. That container serves as an entrypoint to the VuFind application.

Under the `cpk` container is `apache-shibboleth` container, which takes care of properly configuring the [Apache2 httpd](https://httpd.apache.org/) service & the SAML [Shibboleth Service Provider](https://www.shibboleth.net/products/service-provider/), which is an identity management service.

Under the `apache-shibboleth` is `php-extensions` container, which inherits from `php7.1-apache-jessie` container & installs all VuFind prerequisities (mainly according to the [CPK](https://github.com/moravianlibrary/CPK/)'s VuFind implementation). This container also takes care of preparing the power user for productive environment with:

 - bash-completion
 - curl
 - dnsutils
 - git
 - htop
 - iputils-ping
 - iputils-tracepath
 - mc
 - mlocate
 - mysql-client
 - net-tools
 - ssh
 - vim
 
 ### How do I run / install ?
 
 First you'll need to have [the docker](https://docs.docker.com/engine/installation/) installed (Click on the `Docker CE` on the left & pick your OS). Second, your user has to be in the `docker` group, unless you plan to run all docker related commands in privileged mode.
 
 Once you've obtained docker, get docker-compose (using pip is probably the easiest method):
 ```bash
 pip install docker-compose
 ```
 
 Then you'll need the sources to run:
 ```bash
 mkdir vufind && cd vufind
 # Clone the VuFind
 git clone https://github.com/moravianlibrary/CPK.git
 
 # Clone this repository
 git clone https://github.com/jirislav/CPK-docker-compose.git
 ```
 
 Now, you're ready to taste the power of the `docker-compose` :) 
 ```bash
 cd CPK-docker-compose
 
 # Create dummy secrets
 cp secrets/sentry_id.txt{.example,}
 cp secrets/sentry_user_id.txt{.example,}
 
 # Add the hostname beta.knihovny.cz to your /etc/hosts
 echo "127.0.0.1        beta.knihovny.cz" | sudo tee -a /etc/hosts
 
 # Build docker images
 ./make-cpk
 
 # Start CPK container as a daemon
 ./start-cpk -d
 
 # Show running logs
 ./tailf-cpk  # Hit CTRL + c after a while ...
 
 # Visit https://beta.knihovny.cz/ in your browser
 # - it probably won't work because of your missing configuration
 
 # Go and configure your CPK
 cd ..
 cd CPK
 cd local/config/vufind
 cp config.local.ini{.example,}
 vim config.local.ini
 
 # After you're done, you'll see the result immediately in your browser
 ````
