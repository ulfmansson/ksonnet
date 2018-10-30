{
  parts:: {
    web_service:: {
      service(name, port, target_port):: {
          "apiVersion": "v1",
          "kind": "Service",
          "metadata": {
            "labels": {
              "app": name
            },
            "name": "svc-" + name
          },
          "spec": {
            "ports": [
              {
                "port": port,
                "protocol": "TCP",
                "targetPort": target_port
              }
            ],
            "selector": {
                "app": name
            }
         }
      },
      ingress(name, port, host):: {
          "apiVersion": "extensions/v1beta1",
          "kind": "Ingress",  "metadata": {
            "annotations": {
              "certmanager.k8s.io/cluster-issuer": "letsencrypt",
              "kubernetes.io/ingress.class": "nginx",
              "kubernetes.io/tls-acme": "true"
            },
            "name": name
          },
          "spec": {
            "rules": [
              {
                "host": host,
                "http": {
                  "paths": [
                    {
                      "backend": {
                        "serviceName": "svc-" + name + "-api",
                        "servicePort": port
                      },
                      "path": "/"
                    }
                  ]
                }
              }
            ],
            "tls": [
              {
                "hosts": [
                  host
                ],
                "secretName": name + "-crt"
              }
            ]
          }
      },
      certificate(name, domain)::{
          "apiVersion": "certmanager.k8s.io/v1alpha1",
          "kind": "Certificate",
          "metadata": {
            "name": name + "-crt"
          },
          "spec": {
            "acme": {
              "config": [
                {
                  "domains": [
                    domain
                  ],
                  "http01": {
                    "ingressClass": "nginx"
                  }
                }
              ]
            },
            "dnsNames": [
              domain
            ],
            "issuerRef": {
              "kind": "ClusterIssuer",
              "name": "letsencrypt"
            },
            "secretName": name + "-crt"
          }
      }
    }
  }
}

