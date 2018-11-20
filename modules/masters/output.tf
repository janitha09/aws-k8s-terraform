############################
########## OUTPUT ##########
############################

output "public_ip" {
  value = "${aws_instance.cluster.*.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.cluster.*.private_ip}"
}

