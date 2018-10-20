local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["guestbook-ui"];
[
   {
      "apiVersion": "apps/v1beta2",
      "kind": "Deployment",
      "metadata": {
         "name": params.name
      },
      "spec": {
         "replicas": params.replicas,
         "selector": {
            "matchLabels": {
               "app": params.name
            },
         },
         "template": {
            "metadata": {
               "labels": {
                  "app": params.name
               }
            },
            "spec": {
               "containers": [
                  {
                     "image": params.image,
                     "name": params.name
                  }
               ]
            }
         }
      }
   }
]
