local "client_id" {
    expression = vault("/kv/data/azure", "client_id")
    sensitive = true
}
local "client_secret" {
    expression = vault("kv/data/azure", "client_secret")
    sensitive = true
}
local "subscription_id" {
    expression = vault("kv/data/azure", "subscription_id")
    sensitive = true
}
local "tenant_id" {
    expression = vault("kv/data/azure", "tenant_id")
    sensitive = true
}
/*
V2 used here - "kv/data/azure" instead of "kv/azure"
*/