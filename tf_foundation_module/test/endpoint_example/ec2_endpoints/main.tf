############################################
# Module Under Test
############################################

module "ec2_interface_endpoint" {
  source = "../../../../Networking/vpc_endpoints"


  vpc_id              = var.vpc_id
  name_gw_endpoint    = var.name_gw_endpoint
  name_ifce_endpoint  = var.name_ifce_endpoint
  name_plsvc_provider = var.name_plsvc_provider


  # Naming / tagging
  service = var.service
  client  = var.client
  region  = var.region
  env     = var.env
  name    = var.name

  # EC2 Interface service name
  interface_service_name = var.interface_service_name

  # Only EC2 Interface for this example
  create_gateway    = false
  create_interface  = var.create_interface
  create_snowflake  = false
  create_databricks = false

  # AOSS VPC endpoint (OpenSearch Serverless) — toggle from tfvars
  create_aoss        = var.create_aoss
  aoss_endpoint_name = var.aoss_endpoint_name

  # Optional controls
  # If empty, module discovers first private* subnet per AZ
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
}

 