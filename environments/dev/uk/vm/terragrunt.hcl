include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network"]
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//vm"
}

inputs = {
    vm_size = "Standard_B1s"
    tags = {
        "environment": "dev"
    }
}