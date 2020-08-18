output "iam_emr_instance_profile" {
  value = "${aws_iam_instance_profile.segment_emr_instance_profile.name}"
}

output "iam_emr_service_role" {
  value = "${aws_iam_role.segment_emr_service_role.name}"
}

output "iam_emr_autoscaling_role" {
  value = "${aws_iam_role.segment_emr_autoscaling_role.name}"
}
