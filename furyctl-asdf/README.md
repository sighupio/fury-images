# furyctl-asdf

This image is meant to contain all the tools required for delivery.
It's based on [asdf](https://asdf-vm.com/) to manage different packages and versions.

Core packages (default versions):

- asdf (0.8.1)
- furyctl (0.5.0)
- furyagent (0.2.3)

asdf-managed packages (default versions):
- terraform (0.15.0)
- kustomize (3.6.1)
- kubectl (1.19.2)
- kubectx (0.9.3)
- awscli (1.19.0)
- gcloud (344.0.0)
- velero (v1.6.0)

## Use this image

Pulling from `quay.io`
```bash
# Run from anywhere in your system
docker pull quay.io/furyctl-asdf:${TAG}

# Run from your project directory to mount it into the container
docker run -ti -v $PWD:/delivery quay.io/furyctl-asdf:${TAG}
```

Building locally
```bash
# Run from the directory furyctl-asdf which contains the Dockerfile
docker build -t furyctl-asdf .

# Run from your project directory to mount it into the container
docker run -ti -v $PWD:/delivery furyctl-asdf
```

## Use custom versions

### Core packages (Available only with local build)

To change the default versions of Core packages, you have to pass the desired version(s) at build time using the following environment variables:

- ASDF
- FURYAGENT
- FURYCTL

For example, to change furyagent and furyctl version, keeping asdf with its default:

```bash
# Run from the directory furyctl-asdf which contains the Dockerfile
docker build -t furyctl-asdf --build-arg FURYAGENT=0.1.5 --build-arg FURYCTL=0.4.1 .
```

### asdf packages

To change asdf-managed packages, or even add other packages, you need to create a `.tool-versions` file inside your project directory, in the format:

```bash
<PACKAGE1> <VERSION>
<PACKAGE2> <VERSION>
```

For example

```bash
terraform 0.13.0
elixir 1.2.4
```

Inside the container, just execute the following:
```bash
# If you added a new package
asdf plugin add <NEW_PACKAGE>

asdf install
```

Just to check, you can type `asdf current` and see something similar to:

```bash
awscli          1.19.0          /root/.tool-versions
elixir          1.2.4           /delivery/.tool-versions
gcloud          344.0.0         /root/.tool-versions
kubectl         1.19.2          /root/.tool-versions
kubectx         0.9.3           /root/.tool-versions
kustomize       3.6.1           /root/.tool-versions
terraform       0.13.0          /delivery/.tool-versions
velero          v1.6.0          /root/.tool-versions
```