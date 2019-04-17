CDP Continuous Integration Docker Image
=======================================

A Docker image used for building and deploying the Common Data Platform. Main components are:

* `docker-compose`
* `kubectl`
* `kustomize`

## Scripts

The following scripts are available from /usr/bin:

* [version-generator.sh](./deployment-scripts/version-generator.sh): bumps a provided version number
* [git-set-creds-github.sh](./deployment-scripts/git-set-creds-github.sh): sets up ssh to allow to make updates to a github repo, provided a deployment key