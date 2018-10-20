// @apiVersion 0.1
// @name io.ksonnet.pkg.elasticsearch-kibana
// @description Elasticsearch and Kibana stack for logging. Elasticsearch
//   indexes the logs, and kibana provides a queryable, interactive UI.
// @shortDescription The Elasticsearch and Kibana setup for an EFK logging stack.
// @optionalParam namespace string default Namespace in which to put the application

local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["elasticsearch-kibana"];

local k = import 'k.libsonnet';
local ek = import 'ks-ccdp/efk-ccdp/elastic-kibana.libsonnet';

local namespace = params.namespace;

k.core.v1.list.new([
  ek.parts.kibana.deployment(namespace),
  ek.parts.kibana.svc,
  ek.parts.elasticsearch.serviceAccount,
  ek.parts.elasticsearch.clusterRole,
  ek.parts.elasticsearch.clusterRoleBinding(namespace),
  ek.parts.elasticsearch.statefulSet,
  ek.parts.elasticsearch.svc
])
