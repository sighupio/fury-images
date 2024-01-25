# fury-images

This repository contains CI and definition files to build and push general-purpose container images.

Please note that these are **not** the images used by Kubernetes Fury Distribution Modules, even though the repository name could suggest that (see [#65](https://github.com/sighupio/fury-images/issues/65)). For KFD Modules images refer to: https://github.com/sighupio/fury-distribution-container-image-sync

## Multi arch images

By default, all images are built for `amd64` architecture using the `docker build` command.
If you want to build multi-arch images, you can add the platform property to the image spec as follows:

```bash
platforms:
  - linux/arm64
  - linux/amd64
```

This option will cause the build script to use `docker buildx` instead.
