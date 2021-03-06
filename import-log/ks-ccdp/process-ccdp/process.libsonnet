local k = import 'k.libsonnet';
local deployment = k.extensions.v1beta1.deployment;
local container = deployment.mixin.spec.template.spec.containersType;
local volume = deployment.mixin.spec.template.spec.volumesType;

{
  parts:: {
    process::{
        deployment(name, replicas)::{
        local image = 'docker.ccdp.io:5000/' + name,
          "apiVersion": "apps/v1beta2",
          "kind": "Deployment",
          "metadata": {
             "name": name
          },
          "spec": {
             "replicas": replicas,
             "selector": {
                "matchLabels": {
                   "app": name
                },
             },
             "template": {
                "metadata": {
                   "labels": {
                      "app": name
                   }
                },
                "spec": {
                   "containers": [
                      {
                         "image": image,
                         "name": name
                      }
                    ],
                   "imagePullSecrets": [{
                      "name": "ccdp-docker-auth"
                   }]
                }
             }
          }
       },
       name_space(name)::{
           "apiVersion": "v1",
           "kind": "Namespace",
           "metadata": {
              "labels": {
                 "name": name
              },
              "name": name
           }
       }
    }
  }
}
