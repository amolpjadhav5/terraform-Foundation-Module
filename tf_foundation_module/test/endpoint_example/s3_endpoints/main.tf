############################################
# Module Under Test
############################################

module "s3_endpoint" {
  source          = "../../../../networking-modules/private-endpoints"

 name_gw_endpoint = var.name_gw_endpoint
 name_ifce_endpoint = var.name_ifce_endpoint
 name_plsvc_provider = var.name_plsvc_provider
 
  vpc_id = var.vpc_id

  # Naming / tagging
  service = var.service
  client  = var.client
  region  = var.region
  env     = var.env
  name = var.name

  # S3 Gateway service name
  gateway_service_name = var.gateway_service_name

  # Only S3 Gateway for this example
  create_gateway    = true
  create_interface  = false

  # If not provided, the module tries to discover private* route tables
  route_table_ids = var.route_table_ids

  # Optional: custom policy for the S3 Gateway endpoint (null = AWS default)
  policy_json = var.policy_json
}
