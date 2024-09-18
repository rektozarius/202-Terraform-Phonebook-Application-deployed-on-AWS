output "url" {
  description = "Phonebook URL"
  value       = aws_lb.phonebook-alb.dns_name
}