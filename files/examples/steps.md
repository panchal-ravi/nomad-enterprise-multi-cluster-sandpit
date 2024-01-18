----------------------------------------------------------------------
## Namespace Demo 
----------------------------------------------------------------------

### Create namespace for "api" team
nomad namespace apply -region sg ./files/examples/demo/ns/api-dev-namespace.hcl 
nomad namespace list -region sg

### Submit job to a given namespace
nomad job run -region sg ./files/examples/demo/ns/api.hcl 

### Delete job
nomad job stop -namespace api-dev -purge api

### List jobs
nomad job status -namespace api-dev

### Submit job to restricted node pool 
nomad job run -region sg ./files/examples/demo/ns/api-restricted-np.hcl 

### Create resource quota and attach it to namespace
nomad quota apply ./files/examples/demo/ns/api-dev-namespace-quota.hcl 

nomad namespace apply -quota api-dev ./files/examples/demo/ns/api-dev-namespace.hcl 

### Update count in api.hcl and verify quota exceeded error

### Delete job
nomad job stop -namespace api-dev -purge api

### List jobs
nomad job status -namespace api-dev




----------------------------------------------------------------------
## Nomad-Vault Integration using Workload Identity
----------------------------------------------------------------------

### Create namespace for "api" team
nomad namespace apply -region sg ./files/examples/demo/ns/api-dev-namespace.hcl 
nomad namespace list -region sg


nomad job run -region sg ./files/examples/demo/vault/api.hcl 

### Verify Vault secrets and tokens 

nomad alloc exec ---

### Delete job
nomad job stop -namespace api-dev -purge api




----------------------------------------------------------------------
## Nomad-Consul Integration using Workload Identity
----------------------------------------------------------------------

### Create namespace for "api" team
nomad namespace apply -region sg ./files/examples/demo/ns/api-dev-namespace.hcl 
nomad namespace list -region sg


nomad job run -region sg ./files/examples/demo/consul/api.hcl 

### Show "api" service registered in Consul with ACL token generated using Nomad workload identity

### Delete job
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
nomad sentinel apply -level=soft-mandatory prevent-docker-host-network ./files/examples/demo/sentinel/prevent-docker-host-network.sentinel
nomad job run -region sg ./files/examples/demo/sentinel/http_host_net.hcl 
### Submit job with -policy-override
nomad job run -policy-override -region sg ./files/examples/demo/sentinel/http_host_net.hcl 
nomad job stop -region sg -namespace api-dev -purge http 