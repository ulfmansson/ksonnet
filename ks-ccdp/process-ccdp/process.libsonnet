local k = import 'k.libsonnet';
local deployment = k.extensions.v1beta1.deployment;
local container = deployment.mixin.spec.template.spec.containersType;
local volume = deployment.mixin.spec.template.spec.volumesType;

local env_params(env_list) = [
{
  name: item,
  value: env_list[item]
}  for item in std.objectFields(env_list)
];

local secret_key(keys) = [
  {
     name: name,
     key: keys[name]
  } for name in std.objectFields(keys)
  ]
;


local env_secret_params(env_secret_list) = [
{
  name: item,
  valueFrom: {
  foo(key,name ):: {
    name: name
  } ,
     secretKeyRef: env_secret_list[item]
  }
} for item in std.objectFields(env_secret_list)
];

# Will create an env list
local env(env_list, env_secret_list) =
  local total_env_list = env_params(env_list) + env_secret_params(env_secret_list);
  total_env_list
;

{
  parts:: {
    process::{
        deployment(name, version, replicas, env_list, env_secret_list, port)::{
        local image = 'docker.ccdp.io/' + name + ':' + version,
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
                      + if std.length(env_list) > 0 then {env:env(env_list,env_secret_list)} else {}
                      + if port != "" then {ports: [{containerPort: port}]} else {}
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
