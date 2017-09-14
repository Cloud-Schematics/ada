resource "ibm_object_storage_account" "ad_serve_logs" {
  count = "${var.object_storage_enabled}"
}

variable "object_storage_enabled" {
    default = 1
}