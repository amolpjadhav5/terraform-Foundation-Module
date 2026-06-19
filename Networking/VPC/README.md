# terraform-aws-vpc-foundation

Reusable Terraform module for an AWS VPC foundation.

## Creates

- VPC
- Internet Gateway
- Public subnets
- Private subnets
- Database/isolated subnets
- Public route table and default internet route
- Optional NAT Gateway and EIP
- Private route table, shared or per subnet
- Database route table
- Optional RDS DB subnet group

## Usage

See `../../test/example` for a complete example where all module fields are passed as parameters.
