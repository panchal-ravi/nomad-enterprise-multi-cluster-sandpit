/* 
resource "aws_acm_certificate" "cert" {
  private_key       = tls_private_key.consul_server_private_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.consul_server_signed_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem
} 
*/

resource "aws_acm_certificate" "cert" {
  private_key       = var.consul_server_key
  certificate_body  = var.consul_server_crt
  certificate_chain = join("\n", [var.intermediate_ca, var.root_ca])
}

resource "aws_lb_listener" "consul_lb_listener" {
  load_balancer_arn = var.elb_arn
  port              = "8501"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_lb_tg.arn
  }
}

resource "aws_lb_target_group" "consul_lb_tg" {
  name        = "${var.deployment_id}-consul-lb-tg"
  port        = 8501
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/v1/status/leader"
    port                = 8501
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 2
  }
}

resource "aws_lb_target_group_attachment" "consul_lb_tg_attachment" {
  count            = var.consul_server_count
  target_group_arn = aws_lb_target_group.consul_lb_tg.arn
  target_id        = aws_instance.consul_server[count.index].id
  port             = 8501
}