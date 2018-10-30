// @apiVersion 0.1
// @name com.volvocars.ccdp.pkg.process
// @description Create a standard process without ports
// @shortDescription Create a standard process without ports
// @param name string Name to give to each of the components
// @optionalParam version string Version of application to deploy
// @optionalParam replicas number 2 Number of replicas that should run, default is 2
// @optionalParam env_list object {} Environment variable list
// @optionalParam env_secret_list object {} Environment variable list for secrets stored in k8s

local k = import 'k.libsonnet';
local process = import 'ks-ccdp/process-ccdp/process.libsonnet';

local name = import 'param://name';
local version = import 'param://version';
local replicas = import 'param://replicas';
local env_list = import 'param://env_list';
local env_secret_list = import 'param://env_secret_list';

k.core.v1.list.new([
  process.parts.process.name_space(name),
  process.parts.process.deployment(name, version, replicas, env_list, env_secret_list)
])
