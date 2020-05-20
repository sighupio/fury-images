# Drone Kustomize Plugin


```yaml
steps:
  - name: deploy-stage
    image: quay.io/sighup/drone-kustomize:1.15.5_1.0.10
    settings:
      kubeconfig:
        from_secret: kubeconfig
      basepath: deploy/envs/stage
      sha: ${DRONE_COMMIT_SHA:0:8}
      image: yourimage
      rollout_deployment: yourdeployment # optional
      rollout_namespace: your-namespace #optional
```