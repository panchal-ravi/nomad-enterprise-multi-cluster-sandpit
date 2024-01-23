name        = "api-qa"
description = "Namespace for API QA environment."

# Quotas are a Nomad Enterprise feature.
# quota = "eng"

meta {
  owner = "api"
  env = "qa"
}

capabilities {
  enabled_task_drivers  = ["java", "docker"]
  disabled_task_drivers = ["raw_exec"]
}

# Node Pool configuration is a Nomad Enterprise feature.
node_pool_config {
  default = "dev"
  # allowed = ["all", "default"]
  denied  = ["sit"]
}

# Vault configuration is a Nomad Enterprise feature.
# vault {
#   default = "default"
#   allowed = ["default", "infra"]
# }

# Consul configuration is a Nomad Enterprise feature.
# consul {
#   default = "default"
#   allowed = ["all", "default"]
# }
