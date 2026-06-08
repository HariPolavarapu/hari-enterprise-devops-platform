resource "aws_route53_zone" "private_zone" {
  name = "internal.hari"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "jenkins.internal.hari"
  type    = "A"
  ttl     = 300
  records = [var.jenkins_private_ip]
}
