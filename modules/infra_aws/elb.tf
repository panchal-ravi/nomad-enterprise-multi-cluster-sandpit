resource "aws_lb" "http_lb" {
  name                             = "${var.deployment_id}-http-lb"
  internal                         = false
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = false
  subnets                          = module.vpc.public_subnets
  security_groups                  = [module.elb_sg.security_group_id]
  tags = {
    Name = "${var.deployment_id}-http-lb"
  }
}


resource "aws_acm_certificate" "cert" {
  private_key       = tls_private_key.vault_server_private_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.vault_server_signed_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem
}

resource "aws_lb_listener" "vault_lb_listener" {
  load_balancer_arn = aws_lb.http_lb.arn
  port              = "8200"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_lb_tg.arn
  }
}

resource "aws_lb_target_group" "vault_lb_tg" {
  name        = "${var.deployment_id}-vault-lb-tg"
  port        = 8200
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/v1/sys/health"
    port                = 8200
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 2
  }
}

resource "aws_lb_target_group_attachment" "vault_lb_tg_attachment" {
  port             = 8200
  target_group_arn = aws_lb_target_group.vault_lb_tg.arn
  target_id        = aws_instance.vault.id
}
