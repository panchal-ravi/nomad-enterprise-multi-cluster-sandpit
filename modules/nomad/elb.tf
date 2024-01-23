resource "aws_acm_certificate" "cert" {
  private_key       = tls_private_key.nomad_server_private_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.nomad_server_signed_cert.cert_pem
  certificate_chain = var.infra_aws.ca_cert //tls_self_signed_cert.ca_cert.cert_pem
}

resource "aws_lb_listener" "nomad_lb_listener" {
  load_balancer_arn = var.infra_aws.elb_arn
  port              = var.elb_listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad_lb_tg.arn
  }
}

resource "aws_lb_target_group" "nomad_lb_tg" {
  name        = "${var.deployment_id}-nomad-lb-tg-${var.nomad_region}"
  port        = 4646
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.infra_aws.vpc_id

  health_check {
    path                = "/v1/agent/health"
    port                = 4646
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 2
  }
}

resource "aws_lb_target_group_attachment" "nomad_lb_tg_attachment" {
  count            = var.nomad_server_count
  target_group_arn = aws_lb_target_group.nomad_lb_tg.arn
  target_id        = aws_instance.nomad_server[count.index].id
  port             = 4646
}