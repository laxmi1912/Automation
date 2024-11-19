include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//network"
}

inputs = {
    address_space = ["10.0.0.0/16"]
    subnet_address_prefixes = ["10.0.1.0/24"]
}