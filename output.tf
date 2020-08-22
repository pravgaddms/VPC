output "vpc_id" {
  value = "${aws_vpc.my_vpc.id}"
}
output "public_subnets" {
  value = ["${aws_subnet.public_us_east_1a.id}"]
}
output "public_route_table_ids" {
  value = ["${aws_route_table.my_vpc_public.id}"]
}
output "public_instance_ip" {
  value = ["${aws_instance.testInstance.public_ip}"]
}