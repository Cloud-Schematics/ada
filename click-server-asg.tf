# Create a new ssh key 
resource "ibm_compute_ssh_key" "ssh_key_performance" {
  label      = "${var.ssh-label}"
  notes      = "for scale group"
  public_key = "${var.public_key}"
}

resource "ibm_lb" "local_lb" {
  connections = "${var.lb-connections}"
  datacenter  = "${var.lb-datacenter}"
  ha_enabled  = false
  dedicated   = "${var.lb-dedicated}"
}

resource "ibm_lb_service_group" "lb_service_group" {
  port             = "${var.lb-service-group-port}"
  routing_method   = "${var.lb-service-group-routing-method}"
  routing_type     = "${var.lb-service-group-routing-type}"
  load_balancer_id = "${ibm_lb.local_lb.id}"
  allocation       = "${var.lb-service-group-routing-allocation}"
}

resource "ibm_compute_autoscale_group" "sample-http-cluster" {
  name                 = "${var.auto-scale-name}-${random_id.name.hex}"
  regional_group       = "${var.auto-scale-region}"
  cooldown             = "${var.auto-scale-cooldown}"
  minimum_member_count = "${var.auto-scale-minimum-member-count}"
  maximum_member_count = "${var.auto-scale-maximumm-member-count}"
  termination_policy   = "${var.auto-scale-termination-policy}"
  virtual_server_id    = "${ibm_lb_service_group.lb_service_group.id}"
  port                 = "${var.auto-scale-lb-service-port}"

  health_check = {
    type = "${var.auto-scale-lb-service-health-check-type}"
  }

  virtual_guest_member_template = {
    hostname                = "${var.vm-hostname}"
    domain                  = "${var.vm-domain}"
    cores                   = "${var.vm-cores}"
    memory                  = "${var.vm-memory}"
    os_reference_code       = "${var.vm-os-reference-code}"
    datacenter              = "${var.vm-datacenter}"
    ssh_key_ids             = ["${ibm_compute_ssh_key.ssh_key_performance.id}"]
    local_disk              = false
    #post_install_script_uri = "${var.vm-post-install-script-uri}"
  }
}

resource "ibm_compute_autoscale_policy" "sample-http-cluster-policy" {
  name           = "${var.scale-policy-name}"
  scale_type     = "${var.scale-policy-type}"
  scale_amount   = "${var.scale-policy-scale-amount}"
  cooldown       = "${var.scale-policy-cooldown}"
  scale_group_id = "${ibm_compute_autoscale_group.sample-http-cluster.id}"

  triggers = {
    type = "RESOURCE_USE"

    watches = {
      metric   = "host.cpu.percent"
      operator = ">"
      value    = "90"
      period   = 130
    }
  }
}

#ip_address - cluster address
output "cluster_address" {
  value = "http://${ibm_lb.local_lb.ip_address}"
}

variable "public_key" {
  default = ""
}

variable "ssh-label" {
  default = "ssh_key_scale_group"
}

variable "lb-connections" {
  default = 250
}

variable "lb-datacenter" {
  default = "sng01"
}

variable "lb-dedicated" {
  default = false
}

variable "lb-service-group-port" {
  default = 80
}

variable "lb-service-group-routing-method" {
  default = "CONSISTENT_HASH_IP"
}

variable "lb-service-group-routing-type" {
  default = "HTTP"
}

variable "lb-service-group-routing-allocation" {
  default = 100
}

variable "auto-scale-name" {
  default = "sample-http-cluster"
}

variable "auto-scale-region" {
  default = "as-sgp-central-1"
}

variable "auto-scale-cooldown" {
  default = 30
}

variable "auto-scale-minimum-member-count" {
  default = 1
}

variable "auto-scale-maximumm-member-count" {
  default = 10
}

variable "auto-scale-termination-policy" {
  default = "CLOSEST_TO_NEXT_CHARGE"
}

variable "auto-scale-lb-service-port" {
  default = 80
}

variable "auto-scale-lb-service-health-check-type" {
  default = "HTTP"
}

variable "vm-hostname" {
  default = "clickserver"
}

variable "vm-domain" {
  default = "clickserver.test"
}

variable "vm-cores" {
  default = 1
}

variable "vm-memory" {
  default = 4096
}

variable "vm-os-reference-code" {
  default = "CENTOS_7_64"
}

variable "vm-datacenter" {
    default = "sng01"
}

variable "vm-post-install-script-uri" {
  default = "https://raw.githubusercontent.com/hkantare/test/master/nginx.sh"
}

variable "scale-policy-name" {
  default = "scale-policy"
}

variable "scale-policy-type" {
  default = "ABSOLUTE"
}

variable "scale-policy-scale-amount" {
  default = 2
}

variable "scale-policy-cooldown" {
  default = 35
}