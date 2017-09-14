resource "ibm_object_storage_account" "cdn" {
  count = "${var.cdn_enabled}"
}

variable "cdn_enabled" {
    default = 1
}