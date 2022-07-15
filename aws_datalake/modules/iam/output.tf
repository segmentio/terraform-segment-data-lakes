output "iam_emr_instance_profile" {
  value = aws_iam_instance_profile.segment_emr_instance_profile.name
}

output "iam_emr_service_role" {
  value = aws_iam_role.segment_emr_service_role.name
}

output "iam_emr_autoscaling_role" {
  value = aws_iam_role.segment_emr_autoscaling_role.name
}

output "segment_datalake_iam_role_arn" {
  value = aws_iam_role.segment_data_lake_iam_role.arn
}

output "iam_emr_instance_profile_role_arn" {
  value = aws_iam_role.segment_emr_instance_profile_role.arn
}


