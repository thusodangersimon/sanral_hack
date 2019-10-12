# sanral_hack
Base python docker for SANRAL zindi hack
# To build docker run the following commands in bash

`$make create-all` will build docker from scratch and mount user directory so you can edit locally and run them in the docker.

Use `$make help` for list of commands

`$make clean` to remove contatiner and images if you want to install a new package.

`$make run-container` to re-attch container if you stop the container.
