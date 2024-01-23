vault auth enable -path 'jwt-nomad' 'jwt'

vault write auth/jwt-nomad/config '@./files/vault/vault_auth_method_jwt_nomad.json' jwks_ca_pem=@./generated/ca.crt