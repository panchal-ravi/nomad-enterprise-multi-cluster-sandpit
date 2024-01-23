----------------------------------------------------------------------
## Namespace & NodePool Demo 
----------------------------------------------------------------------

### Show NodePools
nomad node pool list
nomad node pool nodes dev
nomad node pool nodes sit

### Create namespace for "api" team
nomad namespace apply -region sg ./files/examples/demo/ns/api-dev-namespace.hcl 
nomad namespace list -region sg
nomad namespace status api-dev

### Submit job to a given namespace
nomad job run -region sg ./files/examples/demo/ns/api.hcl 

nomad job status -namespace api-dev api

### Delete job
nomad job stop -namespace api-dev -purge api

### List jobs
nomad job status -namespace api-dev

### Submit job to restricted node pool 
nomad job run -region sg ./files/examples/demo/ns/api-restricted-np.hcl 


----------------------------------------------------------------------
## Resource Quota Demo 
----------------------------------------------------------------------

### Create resource quota and attach it to namespace
bat ./files/examples/demo/ns/api-dev-namespace-quota.hcl
nomad quota apply ./files/examples/demo/ns/api-dev-namespace-quota.hcl 

### Apply quota to namespace
nomad namespace apply -quota api-dev api-dev 

### Verify quota is applied to a namespace
nomad namespace namespace status api-dev

### Verify quota status
nomad quota status api-dev

### Submit job 
nomad job run -region sg ./files/examples/demo/ns/api.hcl 

### Verify quota status
nomad quota status api-dev

### Update count in api.hcl and verify quota exceeded error
nomad job run -region sg ./files/examples/demo/ns/api.hcl 

### Delete job
nomad job stop -namespace api-dev -purge api

### List jobs
nomad job status -namespace api-dev api

### Remove quota
nomad namespace apply -quota= api-dev

### Delete quota
nomad quota delete api-dev


----------------------------------------------------------------------
## Nomad-Vault Integration using Workload Identity
----------------------------------------------------------------------

### Create namespace for "api" team
nomad namespace apply -region sg ./files/examples/demo/ns/api-dev-namespace.hcl 
nomad namespace list -region sg

bat ./files/examples/demo/vault/api.hcl 
nomad job run -region sg ./files/examples/demo/vault/api.hcl 

### Verify Vault secrets and tokens 

nomad action -namespace api-dev -job api -group api -task api show-secrets

### Delete job
nomad job stop -namespace api-dev -purge api




----------------------------------------------------------------------
## Nomad-Consul Integration using Workload Identity
----------------------------------------------------------------------

### Create namespace for "api" team
nomad namespace apply -region sg ./files/examples/demo/ns/api-dev-namespace.hcl 
nomad namespace list -region sg

bat ./files/examples/demo/consul/api.hcl 
nomad job run -region sg ./files/examples/demo/consul/api.hcl 

### Show "api" service registered in Consul with ACL token generated using Nomad workload identity

### Delete job
nomad job stop -namespace api-dev -purge api

### Nomad-Consul tasks identity
consul kv put 'api/config/cache' '50'
consul kv put 'api/config/maxconn' '100'
consul kv put 'api/config/minconn' '3'

consul kv put -namespace api-dev 'api/config/cache' '500' 
consul kv put -namespace api-dev 'api/config/maxconn' '1000'
consul kv put -namespace api-dev 'api/config/minconn' '30'

nomad job run -region sg ./files/examples/demo/consul/api-tasks.hcl 

nomad alloc exec -namespace api-dev -job api sh
cat local/consul-info.txt

nomad job stop -namespace api-dev -purge api

----------------------------------------------------------------------
## Nomad Sentinel 
----------------------------------------------------------------------
### Test sentinel with default false policy
nomad sentinel apply -level=advisory test-policy ./files/examples/demo/sentinel/test.sentinel
nomad job run -region sg ./files/examples/demo/vault/api.hcl 
nomad job stop -region sg -namespace api-dev -purge api 
nomad sentinel delete test-policy


### Allow tasks with exec driver only
### Apply policy with "advisory" level
nomad sentinel apply -level=advisory allow-execdriver-only-policy ./files/examples/demo/sentinel/allowdriverexeconly.sentinel
nomad job run -region sg ./files/examples/demo/vault/api.hcl 
nomad job stop -region sg -namespace api-dev -purge api 

### Apply policy with "soft-mandatory" level
nomad sentinel apply -level=soft-mandatory allow-execdriver-only ./files/examples/demo/sentinel/allowdriverexeconly.sentinel
nomad job run -region sg ./files/examples/demo/vault/api.hcl 

### Submit the job again with policy-override flag
nomad job run -policy-override -region sg ./files/examples/demo/vault/api.hcl 
nomad job stop -region sg -namespace api-dev -purge api 
nomad sentinel delete allow-execdriver-only

### Prevent tasks with host network
bat ./files/examples/demo/sentinel/prevent-docker-host-network.sentinel
nomad sentinel apply -level=soft-mandatory prevent-docker-host-network ./files/examples/demo/sentinel/prevent-docker-host-network.sentinel

bat ./files/examples/demo/sentinel/http_host_net.hcl 
nomad job run -region sg ./files/examples/demo/sentinel/http_host_net.hcl 

### Delete sentinel policy
nomad sentinel delete prevent-docker-host-network



### Submit job with -policy-override
nomad job run -policy-override -region sg ./files/examples/demo/sentinel/http_host_net.hcl 
nomad job stop -region sg -namespace api-dev -purge http 


----------------------------------------------------------------------
## Nomad Multi-Region 
----------------------------------------------------------------------
bat ./files/examples/demo/multi-region/api.hcl 

nomad job run -region sg ./files/examples/demo/multi-region/api.hcl 
nomad job status api

### Check job allocations in different regions
nomad job allocs -region sg api
nomad job allocs -region my api


nomad job stop -global -purge api 













---------------------------------------------------------------
Terraform module
---------------------------------------------------------------

touch ./generated/nomad_management_token
tfat module.infra_aws
tfat module.vault
tfat module.consul_cluster1
tfat module.consul_cluster2
tfat module.nomad_cluster1
tfat module.nomad_cluster2
tfat module.nomad_vault_workload_identity
tfat module.nomad_consul_cluster1_workload_identity
tfat module.nomad_consul_cluster2_workload_identity

tfdt module.nomad_consul_cluster2_workload_identity
tfdt module.nomad_consul_cluster1_workload_identity
tfdt module.nomad_vault_workload_identity
tfdt module.nomad_cluster2
tfdt module.nomad_cluster1
tfdt module.consul_cluster2
tfdt module.consul_cluster1
tfdt module.vault
tfdt module.infra_aws