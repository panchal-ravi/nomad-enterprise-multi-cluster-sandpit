name = "api-dev-quota"
description = "api-dev quota spec for multiple regions"

# Create a limits for two regions
limit {
    region = "sg"
    region_limit {
        cpu = 300
        memory = 600
    }
}

limit {
    region = "my"
    region_limit {
        cpu = 300
        memory = 600
    }
}
