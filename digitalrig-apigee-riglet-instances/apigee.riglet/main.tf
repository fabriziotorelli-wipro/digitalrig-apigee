provider "aws" {
  region = "${var.region}"
}

module "rancher" {
  source = "../../digitalrig-apigee-iaas-modules/terraform/modules/aws/rancher-minimal"

  region = "${var.region}"
  vpc-net-cidr = "${var.vpc-net-cidr}"
  dmz-net-cidr = "${var.dmz-net-cidr}"
  dmz-availability-zone = "${var.dmz-availability-zone}"
  internal-net-cidr = "${var.internal-net-cidr}"
  internal-net-prefix = "${var.internal-net-prefix}"
  internal-availability-zone = "${var.internal-availability-zone}"

  ansible-domain = "${var.ansible-domain}"
  route-53-domain-id = "${var.route-53-domain-id}"
  ad-type = "${var.ad-type}"

  ad-krb-realm = "${var.ad-krb-realm}"
  krb-domain = "${var.krb-domain}"
  base-dn = "${var.base-dn}"
  ad-password = "${var.ad-password}"

  keypair = "${var.keypair}"
  internal-keypair = "${var.internal-keypair}"

  # Change the inventory name to be used, only if needed
  ansible-inventory = "riglet-rancher"
  dr-scripts-ref = "${var.dr-scripts-ref}"
  digitalrig-riglet-ref = "${var.digitalrig-riglet-ref}"
  platform-ref = "${var.platform-ref}"

  default-linux-ami = "${var.default-linux-ami}"
  rancheros-ami = "${var.rancheros-ami}"

  vpn-knock-lower-port = "${var.vpn-knock-lower-port}"
  vpn-knock-upper-port = "${var.vpn-knock-upper-port}"
}

output "front-end-private-ip" {
  value = "${module.apigee.aws-front-end-private-ip}"
}

output "front-end-public-ip" {
  value = "${module.apigee.aws-front-end-public-ip}"
}

output "gateway-private-ip" {
  value = "${module.apigee.aws-gateway-private-ip}"
}

output "gateway-public-ip" {
  value = "${module.apigee.aws-gateway-public-ip}"
}

output "docker-ci-cd-private-ip" {
  value = "${module.apigee.aws-docker-ci-cd-private-ip}"
}

output "openvpn-host" {
  value = "${module.apigee.openvpn-dns}"
}

output "ad-admin-box-ip" {
  value = "${module.apigee.aws-admin-private-ip}"
}

output "ad-dns-1" {
  value = "${module.apigee.ad-dns-1}"
}

output "ad-dns-2" {
  value = "${module.apigee.ad-dns-2}"
}

output "riglet-vpc-id" {
  value = "${module.apigee.default-vpc-id}"
}

output "rig-internal-route-table-id" {
 value = "${module.apigee.internal-route-table-id}"
}

output "rig-dmz-route-table-id" {
 value = "${module.apigee.dmz-route-table-id}"
}

output "rig-route53-internal-zone-id" {
 value = "${module.apigee.route53-internal-zone-id}"
}

output "rig-default-security-group-id" {
  value = "${module.apigee.default-security-group-id}"
}

output "rig-private-subnet-id" {
  value = "${module.apigee.private-subnet-id}"
}
