local k = import 'k.libsonnet';
local deployment = k.extensions.v1beta1.deployment;
local container = deployment.mixin.spec.template.spec.containersType;
local volume = deployment.mixin.spec.template.spec.volumesType;

{
  parts:: {
    fluentd::{
      config_map(data)::{
          "apiVersion": "v1",
           "kind": "ConfigMap",
           "metadata":{
                "name":"fluentd"
           },
          "data": data
     },
     service_account()::{
          "apiVersion": "v1",
          "kind": "ServiceAccount",
          "metadata": {
            "name": "fluentd"
          }
     },
     cluster_role()::{
          "apiVersion": "rbac.authorization.k8s.io/v1",
          "kind": "ClusterRole",
          "metadata": {
            "name": "fluentd"
          },
          "rules": [
            {
              "apiGroups": [
                ""
              ],
              "resources": [
                "namespaces",
                "pods"
              ],
              "verbs": [
                "get",
                "watch",
                "list"
              ]
            }
          ]

     },
     cluster_role_binding(namespace)::{
          "apiVersion": "rbac.authorization.k8s.io/v1",
          "kind": "ClusterRoleBinding",
          "metadata": {
            "name": "fluentd"
          },
          "roleRef": {
            "apiGroup": "rbac.authorization.k8s.io",
            "kind": "ClusterRole",
            "name": "fluentd"
          },
          "subjects": [
            {
              "kind": "ServiceAccount",
              "name": "fluentd",
              "namespace": namespace
            }
          ]
        },
     deamon_set()::{
          "apiVersion": "apps/v1beta2",
          "kind": "DaemonSet",
          "metadata": {
            "labels": {
              "app": "fluentd"
            },
            "name": "fluentd"
          },
          "spec": {
             "selector": {
                  "matchLabels": {
                    "app": "fluentd"
                  }
            },
            "template": {
              "metadata": {
                "labels": {
                  "app": "fluentd"
                }
              },
              "spec": {
                "containers": [
                  {
                    "env": [
                      {
                        "name": "FLUENTD_ARGS",
                        "value": "--no-supervisor -q"
                      }
                    ],
                    "image": "gcr.io/google-containers/fluentd-elasticsearch:v2.0.3",
                    "imagePullPolicy": "IfNotPresent",
                    "name": "fluentd",
                    "resources": {
                      "limits": {
                        "cpu": "100m",
                        "memory": "900Mi"
                      },
                      "requests": {
                        "cpu": "100m",
                        "memory": "200Mi"
                      }
                    },
                    "volumeMounts": [
                      {
                        "mountPath": "/var/log",
                        "name": "varlog"
                      },
                      {
                        "mountPath": "/var/lib/docker/containers",
                        "name": "varlibdockercontainers",
                        "readOnly": true
                      },
                      {
                        "mountPath": "/host/lib",
                        "name": "libsystemddir",
                        "readOnly": true
                      },
                      {
                        "mountPath": "/etc/fluent/config.d",
                        "name": "config-volume"
                      }
                    ]
                  }
                ],
                "serviceAccountName": "fluentd",
                "terminationGracePeriodSeconds": null,
                "volumes": [
                  {
                    "hostPath": {
                      "path": "/var/log"
                    },
                    "name": "varlog"
                  },
                  {
                    "hostPath": {
                      "path": "/var/lib/docker/containers"
                    },
                    "name": "varlibdockercontainers"
                  },
                  {
                    "hostPath": {
                      "path": "/usr/lib64"
                    },
                    "name": "libsystemddir"
                  },
                  {
                    "configMap": {
                      "name": "fluentd"
                    },
                    "name": "config-volume"
                  }
                ]
              }
            }
          }
        }
    }
  }
}
