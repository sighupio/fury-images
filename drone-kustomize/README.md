# Drone Kustomize Plugin


```yaml
steps:
  - name: deploy-stage
    image: sighupio/drone-kustomize:v1.0.10
    settings:
      kubeconfig:
        from_secret: kubeconfig
      basepath: deploy/envs/stage
```