output "endpoint_ids" {
  description = "IDs of the VPC endpoints used for private AWS service connectivity."
  value = merge(
    {
      ecr_api = aws_vpc_endpoint.ecr_api.id
      ecr_dkr = aws_vpc_endpoint.ecr_dkr.id
      logs    = aws_vpc_endpoint.logs.id
      s3      = aws_vpc_endpoint.s3.id
    },
    var.bedrock_runtime_endpoint_enabled ? {
      bedrock_runtime = aws_vpc_endpoint.bedrock_runtime[0].id
    } : {}
  )
}
