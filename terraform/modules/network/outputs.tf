output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.app.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "private_route_table_id" {
  description = "ID of the route table associated with the private subnets."
  value       = aws_route_table.private.id
}

output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group."
  value       = aws_security_group.alb.id
}

output "ecs_task_security_group_id" {
  description = "ID of the ECS task security group."
  value       = aws_security_group.ecs_tasks.id
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the VPC endpoint security group."
  value       = aws_security_group.vpc_endpoints.id
}
