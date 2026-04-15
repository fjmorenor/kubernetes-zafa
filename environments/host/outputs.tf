output "vpc_self_link" {
  value = module.network.vpc_self_link
}

output "subnet_standard_self_link" {
  value = module.network.subnet_standard_id
}

  output "subnet_autopilot_self_link"{
    value = module.network.subnet_autopilot_id
}