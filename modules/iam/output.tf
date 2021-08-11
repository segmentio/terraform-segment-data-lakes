output "iam_emr_instance_profile_name" {
  value = aws_iam_instance_profile.segment_emr_instance_profile.name
}

output "iam_emr_instance_profile_arn" {
  value = aws_iam_instance_profile.segment_emr_instance_profile.arn
}

output "iam_emr_service_role_name" {
  value = aws_iam_role.segment_emr_service_role.name
}

output "iam_emr_autoscaling_role_arn" {
  value = aws_iam_role.segment_emr_autoscaling_role.arn
}

output "iam_segment_data_lake_role_name" {
  value = aws_iam_role.segment_data_lake_iam_role.name
}

output "iam_segment_data_lake_role_arn" {
  value = aws_iam_role.segment_data_lake_iam_role.arn
}
