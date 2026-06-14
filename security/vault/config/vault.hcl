ui = true
disable_mlock = false

storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  tls_disable     = false
  tls_cert_file   = "/vault/tls/tls.crt"
  tls_key_file    = "/vault/tls/tls.key"
}

# Replace with the actual Vault server address during deployment.
# Example: api_addr = "https://vault.prod.internal:8200"
api_addr = "https://vault.local.invalid:8200"
