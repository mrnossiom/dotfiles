# Terraform config

## Secrets

Fill `secrets.auto.tfvars` with

```tfvars
hcloud_token = "token"
```

## Commands

```
tofu init
tofu plan
tofu apply
```

## Extract generated

```sh
tofu show -json | jq -j '.values.root_module.resources[] | select(.address=="hcloud_storage_box.rowrack") | .values.password' | wl-copy
tofu show -json | jq -j '.values.root_module.resources[] | select(.address=="hcloud_storage_box_subaccount.rowrack_tangled") | .values.password' | wl-copy
```
