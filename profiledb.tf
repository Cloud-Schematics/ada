resource "ibm_service_instance" "profiledb" {
  name       = "profiledb-${random_id.name.hex}"
  space_guid = "${data.ibm_space.space.id}"
  service    = "${var.profiledb_service_offering}"
  plan       = "${var.profiledb_plan}"
  tags       = ["schematics", "adserver"]
}

resource "ibm_service_key" "profiledb_key" {
  name                  = "profiledb-key-${random_id.name.hex}"
  service_instance_guid = "${ibm_service_instance.profiledb.id}"
}

variable "profiledb_service_offering" {
  default = "cloudantNoSQLDB"
}

variable "profiledb_plan" {
  default = "Lite"
}
