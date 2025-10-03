output "vpc_id" {
  value = aws_vpc.main_vpc.id
}
output "apci_jupiter_public_subnet_az_1a" {
  value = aws_subnet.apci-jupiter_public_subnet_az_1a.id
  
}
output "apci_jupiter_public_subnet_az_1c" {
  value = aws_subnet.apci-jupiter_public_subnet_az_1c.id
  
}

output "apci_jupiter_private_subnet_az_1a" {
  value = aws_subnet.apci-jupiter_private_subnet_az_1a.id
}

output "apci_jupiter_private_subnet_az_1c" {
  value = aws_subnet.apci-jupiter_private_subnet_az_1c.id
}

output "apci_jupiter_db_subnet_az_1a" {
  value = aws_subnet.apci-jupiter_db_subnet_az_1a.id
}

output "apci_jupiter_db_subnet_az_1c" {
  value = aws_subnet.apci-jupiter_db_subnet_az_1c.id
}