include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network", "../vm"]
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//trafficmanager"
}

