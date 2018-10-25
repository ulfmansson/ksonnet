// @apiVersion 0.1
// @name com.volvocars.ccdp.pkg.process
// @description Create a standard process without ports
// @shortDescription Create a standard process without ports
// @param name string Name to give to each of the components
// @optionalParam replicas number 2 Number of replicas that should run, default is 2
// @optionalParam env_list object {} Environment variable list

local k = import 'k.libsonnet';
local process = import 'ks-ccdp/process-ccdp/process.libsonnet';

local name = import 'param://name';
local replicas = import 'param://replicas';
local env_list = import 'param://env_list';

k.core.v1.list.new([
  process.parts.process.name_space(params.name),
  process.parts.process.deployment(params.name, params.replicas, params.env_list)
])