local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["proc1"];

local k = import 'k.libsonnet';
local process = import 'ks-ccdp/process-ccdp/process.libsonnet';

local name = params.name;
local image = params.image;
local replicas = params.replicas;

k.core.v1.list.new([
  process.parts.process.name_space(params.name),
  process.parts.process.deployment(params.name, params.image, params.replicas)
])
