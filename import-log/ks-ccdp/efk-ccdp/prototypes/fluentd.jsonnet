// @apiVersion 0.0.1
// @name io.ksonnet.pkg.fluentd
// @description A fluent installation configured with confs
// @shortDescription The fluent installation configured with confs
// @param namespace string Namespace where it will run

local k = import 'k.libsonnet';
local fluentd = import 'ks-ccdp/efk-ccdp/fluentd.libsonnet';

local namespace = import 'param://namespace';

local output_conf = (importstr '../../fluent/conf/output.conf');
local output_conf_fixed = output_conf % ["elasticsearch-logging.elk", "9200"];

local fluent_config_data = {
    "containers.input.conf": importstr '../../fluent/conf/containers.input.conf',
    "forward.input.conf": importstr '../../fluent/conf/forward.input.conf',
    "monitoring.conf": importstr '../../fluent/conf/monitoring.conf',
    "system.conf": importstr '../../fluent/conf/system.conf',
    "systen.input.conf": importstr '../../fluent/conf/system.input.conf',
    "output.conf" : output_conf_fixed
};

k.core.v1.list.new([
  fluentd.parts.fluentd.config_map(fluent_config_data),
  fluentd.parts.fluentd.deamon_set(),
  fluentd.parts.fluentd.service_account(),
  fluentd.parts.fluentd.cluster_role(),
  fluentd.parts.fluentd.cluster_role_binding(namespace)
])