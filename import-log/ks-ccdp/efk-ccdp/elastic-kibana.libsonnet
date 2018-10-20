local k = import 'k.libsonnet';
local deployment = k.extensions.v1beta1.deployment;
local container = deployment.mixin.spec.template.spec.containersType;
local volume = deployment.mixin.spec.template.spec.volumesType;
local es_version = "6.4.2";

// TODO: Very clearly WIP, needs to be refactored
{
  parts:: {
    kibana::{
      deployment(namespace)::{
          "apiVersion":"apps/v1beta1",
          "kind":"Deployment",
          "metadata":{
            "name":"kibana-logging",
            "labels":{
                "k8s-app":"kibana-logging",
                "kubernetes.io/cluster-service":"true",
                "addonmanager.kubernetes.io/mode":"Reconcile"
            }
          },
          "spec":{
            "replicas":1,
            "selector":{
                "matchLabels":{
                  "k8s-app":"kibana-logging"
                }
            },
            "template":{
                "metadata":{
                  "labels":{
                      "k8s-app":"kibana-logging"
                  }
                },
                "spec":{
                  "containers":[
                      {
                        "name":"kibana-logging",
                        "image":"docker.elastic.co/kibana/kibana:" + es_version,
                        "resources":{
                            "limits":{
                              "cpu":"1000m"
                            },
                            "requests":{
                              "cpu":"100m"
                            }
                        },
                        "env":[
                            {
                              "name":"ELASTICSEARCH_URL",
                              "value":"http://elasticsearch-logging.elk:9200"
                            },
                            {
                              "name":"XPACK_MONITORING_ENABLED",
                              "value":"false"
                            },
                            {
                              "name":"XPACK_SECURITY_ENABLED",
                              "value":"false"
                            }
                        ],
                        "ports":[
                            {
                              "containerPort":5601,
                              "name":"ui",
                              "protocol":"TCP"
                            }
                        ]
                      }
                  ]
                }
            }
          }
      },
      svc::{
          "apiVersion":"v1",
          "kind":"Service",
          "metadata":{
            "name":"kibana-logging",
            "labels":{
                "k8s-app":"kibana-logging",
                "kubernetes.io/cluster-service":"true",
                "addonmanager.kubernetes.io/mode":"Reconcile",
                "kubernetes.io/name":"Kibana"
            }
          },
          "spec":{
            "ports":[
                {
                  "port":5601,
                  "protocol":"TCP",
                  "targetPort":"ui"
                }
            ],
            "type":"NodePort",
            "selector":{
                "k8s-app":"kibana-logging"
            }
          }
      },

    },
    elasticsearch::{
      serviceAccount::{
          "apiVersion":"v1",
          "kind":"ServiceAccount",
          "metadata":{
            "name":"elasticsearch-logging",
            "labels":{
                "k8s-app":"elasticsearch-logging",
                "kubernetes.io/cluster-service":"true",
                "addonmanager.kubernetes.io/mode":"Reconcile"
            }
          }
      },
      clusterRole::{
          "kind":"ClusterRole",
          "apiVersion":"rbac.authorization.k8s.io/v1beta1",
          "metadata":{
            "name":"elasticsearch-logging",
            "labels":{
                "k8s-app":"elasticsearch-logging",
                "kubernetes.io/cluster-service":"true",
                "addonmanager.kubernetes.io/mode":"Reconcile"
            }
          },
          "rules":[
            {
                "apiGroups":[
                  ""
                ],
                "resources":[
                  "services",
                  "namespaces",
                  "endpoints"
                ],
                "verbs":[
                  "get"
                ]
            }
          ]
      },
      clusterRoleBinding(namespace)::{
          "kind":"ClusterRoleBinding",
          "apiVersion":"rbac.authorization.k8s.io/v1beta1",
          "metadata":{
            "name":"elasticsearch-logging",
            "namespace": namespace,
            "labels":{
                "k8s-app":"elasticsearch-logging",
                "kubernetes.io/cluster-service":"true",
                "addonmanager.kubernetes.io/mode":"Reconcile"
            }
          },
          "subjects":[
            {
                "kind":"ServiceAccount",
                "name":"elasticsearch-logging",
                "apiGroup":"",
                "namespace": namespace
            }
          ],
          "roleRef":{
            "kind":"ClusterRole",
            "name":"elasticsearch-logging",
            "apiGroup": "rbac.authorization.k8s.io"
          }
      },
      statefulSet::{
          "apiVersion":"apps/v1beta1",
          "kind":"StatefulSet",
          "metadata":{
            "name":"elasticsearch-logging",
            "labels":{
                "k8s-app":"elasticsearch-logging",
                "version":"v5.6.2",
                "kubernetes.io/cluster-service":"true",
                "addonmanager.kubernetes.io/mode":"Reconcile"
            }
          },
          "spec":{
            "serviceName":"elasticsearch-logging",
            "replicas":2,
            "selector":{
                "matchLabels":{
                  "k8s-app":"elasticsearch-logging",
                  "version":"v5.6.2"
                }
            },
            "template":{
                "metadata":{
                  "labels":{
                      "k8s-app":"elasticsearch-logging",
                      "version":"v5.6.2",
                      "kubernetes.io/cluster-service":"true"
                  }
                },
                "spec":{
                  "serviceAccountName":"elasticsearch-logging",
                  "containers":[
                      {
                        "image":"docker.elastic.co/elasticsearch/elasticsearch:" + es_version,
                        "name":"elasticsearch-logging",
                        "resources":{
                            "limits":{
                              "cpu":"1000m"
                            },
                            "requests":{
                              "cpu":"100m"
                            }
                        },
                        "ports":[
                            {
                              "containerPort":9200,
                              "name":"db",
                              "protocol":"TCP"
                            },
                            {
                              "containerPort":9300,
                              "name":"transport",
                              "protocol":"TCP"
                            }
                        ],
                        "volumeMounts":[
                            {
                              "name":"elasticsearch-logging",
                              "mountPath":"/data"
                            }
                        ],
                        "env":[
                            {
                              "name":"NAMESPACE",
                              "valueFrom":{
                                  "fieldRef":{
                                    "fieldPath":"metadata.namespace"
                                  }
                              }
                            }
                        ]
                      }
                  ],
                  "volumes":[
                      {
                        "name":"elasticsearch-logging",
                        "emptyDir":{

                        }
                      }
                  ],
                  "initContainers":[
                      {
                        "image":"alpine:3.6",
                        "command":[
                            "/sbin/sysctl",
                            "-w",
                            "vm.max_map_count=262144"
                        ],
                        "name":"elasticsearch-logging-init",
                        "securityContext":{
                            "privileged":true
                        }
                      }
                  ]
                }
            }
          }
      },
      svc::{
          "apiVersion":"v1",
          "kind":"Service",
          "metadata":{
            "name":"elasticsearch-logging",
            "labels":{
                "k8s-app":"elasticsearch-logging",
                "kubernetes.io/cluster-service":"true",
                "addonmanager.kubernetes.io/mode":"Reconcile",
                "kubernetes.io/name":"Elasticsearch"
            }
          },
          "spec":{
            "ports":[
                {
                  "port":9200,
                  "protocol":"TCP",
                  "targetPort":"db"
                }
            ],
            "selector":{
                "k8s-app":"elasticsearch-logging"
            }
          }
      }
    }
  }
}
