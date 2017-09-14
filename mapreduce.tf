resource "ibm_service_instance" "biginsights" {
  name       = "biginsights-${random_id.name.hex}"
  space_guid = "${data.ibm_space.space.id}"
  service    = "${var.biginsights_service}"
  plan       = "${var.biginsights_plan}"
  tags       = ["schematics", "adserver"]
}

# The Bluemix CF identifier for biginsights
# Can be obtained from CLI: `bx cf marketplace`
variable "biginsights_service" {
  description = "The Bluemix CF identifier for BigInsights."
  default = "BigInsightsForApacheHadoop"
}

# The Bluemix CF Plan for biginsights
# Can be obtained from CLI: `bx cf marketplace`
variable "biginsights_plan" {
  description = "The Bluemix CF plan for BigInsights."
  default = "Basic"
}
