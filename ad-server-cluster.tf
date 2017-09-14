resource "ibm_container_cluster" "ad_server_cluster" {
  count        = "${var.create_ad_server}"

  name         = "ad-server-cluster-${random_id.name.hex}"
  datacenter   = "${var.datacenter}"
  org_guid     = "${data.ibm_org.org.id}"
  space_guid   = "${data.ibm_space.space.id}"
  account_guid = "${data.ibm_account.account.id}"
  no_subnet    = true
  subnet_id    = ["${var.subnet_id}"]

  workers = [
    {
      name   = "worker1"
      action = "add"
    },
  ]

  machine_type    = "${var.machine_type}"
  isolation       = "${var.isolation}"
  public_vlan_id  = "${var.public_vlan_id}"
  private_vlan_id = "${var.private_vlan_id}"
}

resource "ibm_container_bind_service" "profiledb_bind_service" {
  count        = "${var.create_ad_server}"

  cluster_name_id             = "${ibm_container_cluster.ad_server_cluster.name}"
  service_instance_space_guid = "${data.ibm_space.space.id}"
  service_instance_name_id    = "${ibm_service_instance.profiledb.id}"
  namespace_id                = "default"
  org_guid                    = "${data.ibm_org.org.id}"
  space_guid                  = "${data.ibm_space.space.id}"
  account_guid                = "${data.ibm_account.account.id}"
}

data "ibm_container_cluster_config" "cluster_config" {
  count        = "${var.create_ad_server}"

  cluster_name_id = "${ibm_container_cluster.ad_server_cluster.name}"
  org_guid        = "${data.ibm_org.org.id}"
  space_guid      = "${data.ibm_space.space.id}"
  account_guid    = "${data.ibm_account.account.id}"
}

variable "region" {}
variable "datacenter" {}
variable "machine_type" {}
variable "isolation" {}
variable "private_vlan_id" {}
variable "public_vlan_id" {}
variable "subnet_id" {}

variable "create_ad_server" {
  default = 0
}

