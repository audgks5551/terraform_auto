output "akbunalb_dns" {
  value       = aws_lb.lb-1.dns_name
  description = "The DNS Address of the ALB"
}
