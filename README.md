# terraform-aws-monorepo
Terraform modules

# modules

1. [vpc](vpc)
```
module "vpc" {
  source = "github.com/GimhanDissanayake/terraform-aws-monorepo.git//vpc?ref=vpc-v1.0.0"

  project     = "alian"
  environment = "dev"

  cidr                  = "10.0.0.0/16"
  secondary_cidr_blocks = ["10.1.0.0/16"]
  public_subnets        = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24"]
  private_subnets       = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24", "10.1.21.0/24"]

  enable_nat_gateway = true

  enable_vpc_peering = true

  vpc_peering_connections = [
    {
      peer_owner_id       = "7777777777777"
      peer_region         = "us-west-1"
      peer_vpc_id         = "vpc-7777777777777777"
      acceptor_cidr_block = "10.10.0.0/16"
    }
  ]
}
```

# Release
```
git tag vpc-v1.0.0
git push origin vpc-v1.0.0
```