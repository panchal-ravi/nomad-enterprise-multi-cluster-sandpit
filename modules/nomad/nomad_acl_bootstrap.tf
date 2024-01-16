resource "time_sleep" "wait_for_nomad" {
  depends_on = [aws_instance.nomad_server, aws_lb_target_group_attachment.nomad_lb_tg_attachment]

  create_duration = "30s"
}

resource null_resource "nomad_acl_bootstrap" {
    count = var.nomad_region == var.nomad_authoritative_region ? 1 : 0
    provisioner "local-exec" {
      command = <<-EOF
        curl -s -k -X POST https://${var.elb_http_addr}:${var.elb_listener_port}/v1/acl/bootstrap | jq -r .SecretID > ${path.root}/generated/nomad_management_token
      EOF
    }

    depends_on = [ time_sleep.wait_for_nomad ]
}
