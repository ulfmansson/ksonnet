// @apiVersion 0.1
// @name com.volvocars.ccdp.pkg.web-service-ccdp
// @description Create a standard web service
// @shortDescription Create a standard web service
// @param name string Name to give to each of the components
// @param host string The host name
// @param domain string The domain
// @optionalParam version string   Version of application to deploy
// @optionalParam replicas number 2 Number of replicas that should run, default is 2
// @optionalParam env_list object {} Environment variable list
// @optionalParam env_secret_list object {} Environment variable list for secrets stored in k8s
// @optionalParam port number 80 The port number
// @optionalParam target_port number 80 The target port

local k = import 'k.libsonnet';
local process = import 'ks-ccdp/process-ccdp/process.libsonnet';
local web_service = import 'ks-ccdp/web-service-ccdp/web-service.libsonnet';
local name = import 'param://name';
local version = import 'param://version';
local replicas = import 'param://replicas';
local env_list = import 'param://env_list';
local env_secret_list = import 'param://env_secret_list';
local port = import 'param://port';
local target_port = import 'param://target_port';
local host = import 'param://host';
local domain = import 'param://domain';

k.core.v1.list.new([
  process.parts.process.deployment(name, version, replicas, env_list, env_secret_list, port),
  web_service.parts.web_service.service(name, port, target_port),
  web_service.parts.web_service.ingress(name, port, host),
  web_service.parts.web_service.certificate(name, domain)
])
