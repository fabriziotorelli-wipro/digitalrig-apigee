resource "aws_s3_bucket" "apigee-backup" {
  bucket = "apigee-${replace(var.ansible-domain, ".", "-")}"
  acl = "private"
  region = "${var.region}"
  force_destroy= true
}
resource "aws_s3_bucket" "apigee-docker-registry" {
  bucket = "apigee-registry-${replace(var.ansible-domain, ".", "-")}"
  acl = "private"
  region = "${var.region}"
  force_destroy= true
}
