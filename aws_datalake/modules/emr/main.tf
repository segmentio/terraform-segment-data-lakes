# Creates an EMR cluster that will be used to transform and load events into the Data Lake.
# https://www.terraform.io/docs/providers/aws/r/emr_cluster.html
resource "aws_emr_cluster" "segment_data_lake_emr_cluster" {
  name          = var.cluster_name
  release_label = "emr-${var.emr_cluster_version}"
  applications  = concat(["Hadoop", "Hive", "Spark"], var.additional_applications)

  log_uri = "s3://${var.s3_bucket}/${var.emr_logs_s3_prefix}"

  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = var.master_security_group
    additional_master_security_groups = var.additional_master_security_groups
    emr_managed_slave_security_group  = var.slave_security_group
    additional_slave_security_groups  = var.additional_slave_security_groups
    instance_profile                  = var.iam_emr_instance_profile
    key_name                          = var.key_name
  }

  service_role     = var.iam_emr_service_role
  autoscaling_role = var.iam_emr_autoscaling_role
  #unhealthy_node_replacement = var.unhealthy_node_replacement

  master_instance_group {
    instance_type = var.master_instance_type
    name          = "master_group"

    ebs_config {
      size                 = var.ebs_size
      type                 = var.ebs_type
      volumes_per_instance = 1
    }
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
    name           = "core_group"

    ebs_config {
      size                 = var.ebs_size
      type                 = var.ebs_type
      volumes_per_instance = 1
    }

    autoscaling_policy = <<EOF
{
	"Constraints": {
		"MinCapacity": ${var.core_instance_count},
		"MaxCapacity": ${var.core_instance_max_count}
	},
	"Rules": [{
		"Action": {
			"SimpleScalingPolicyConfiguration": {
				"ScalingAdjustment": 1,
				"CoolDown": 300,
				"AdjustmentType": "CHANGE_IN_CAPACITY"
			}
		},
		"Description": "",
		"Trigger": {
			"CloudWatchAlarmDefinition": {
				"MetricName": "HDFSUtilization",
				"ComparisonOperator": "GREATER_THAN_OR_EQUAL",
				"Statistic": "AVERAGE",
				"Period": 300,
				"EvaluationPeriods": 1,
				"Unit": "PERCENT",
				"Namespace": "AWS/ElasticMapReduce",
				"Threshold": 80
			}
		},
		"Name": "ScaleOutHDFSUtilization"
	}, {
		"Action": {
			"SimpleScalingPolicyConfiguration": {
				"ScalingAdjustment": -1,
				"CoolDown": 300,
				"AdjustmentType": "CHANGE_IN_CAPACITY"
			}
		},
		"Description": "",
		"Trigger": {
			"CloudWatchAlarmDefinition": {
				"MetricName": "HDFSUtilization",
				"ComparisonOperator": "LESS_THAN",
				"Statistic": "AVERAGE",
				"Period": 300,
				"EvaluationPeriods": 1,
				"Unit": "PERCENT",
				"Namespace": "AWS/ElasticMapReduce",
				"Threshold": 50
			}
		},
		"Name": "ScaleInMemoryPercentage"
	}]
}
EOF
  }

  configurations_json = var.configurations_json
  tags = local.tags
}

resource "aws_emr_instance_group" "task" {
  name       = "task_group"
  cluster_id = aws_emr_cluster.segment_data_lake_emr_cluster.id

  instance_type  = var.task_instance_type
  instance_count = var.task_instance_count

  ebs_config {
    size                 = var.ebs_size
    type                 = var.ebs_type
    volumes_per_instance = 1
  }

  autoscaling_policy = <<EOF
{
"Constraints": {
			"MinCapacity": ${var.task_instance_count},
			"MaxCapacity": ${var.task_instance_max_count}
		},
		"Rules": [{
			"Action": {
				"SimpleScalingPolicyConfiguration": {
					"ScalingAdjustment": 1,
					"CoolDown": 120,
					"AdjustmentType": "CHANGE_IN_CAPACITY"
				}
			},
			"Description": "",
			"Trigger": {
				"CloudWatchAlarmDefinition": {
					"MetricName": "ContainerPendingRatio",
					"ComparisonOperator": "GREATER_THAN_OR_EQUAL",
					"Statistic": "AVERAGE",
					"Period": 300,
					"EvaluationPeriods": 1,
					"Unit": "COUNT",
					"Namespace": "AWS/ElasticMapReduce",
					"Threshold": 0.75
				}
			},
			"Name": "ScaleOutContainersPending"
		}, {
			"Action": {
				"SimpleScalingPolicyConfiguration": {
					"ScalingAdjustment": 1,
					"CoolDown": 120,
					"AdjustmentType": "CHANGE_IN_CAPACITY"
				}
			},
			"Description": "",
			"Trigger": {
				"CloudWatchAlarmDefinition": {
					"MetricName": "YARNMemoryAvailablePercentage",
					"ComparisonOperator": "LESS_THAN_OR_EQUAL",
					"Statistic": "AVERAGE",
					"Period": 300,
					"EvaluationPeriods": 1,
					"Unit": "PERCENT",
					"Namespace": "AWS/ElasticMapReduce",
					"Threshold": 15
				}
			},
			"Name": "ScaleOutYarnMemoryUtilization"
		}, {
			"Action": {
				"SimpleScalingPolicyConfiguration": {
					"ScalingAdjustment": -1,
					"CoolDown": 120,
					"AdjustmentType": "CHANGE_IN_CAPACITY"
				}
			},
			"Description": "",
			"Trigger": {
				"CloudWatchAlarmDefinition": {
					"MetricName": "ContainerPendingRatio",
					"ComparisonOperator": "GREATER_THAN_OR_EQUAL",
					"Statistic": "AVERAGE",
					"Period": 300,
					"EvaluationPeriods": 1,
					"Unit": "COUNT",
					"Namespace": "AWS/ElasticMapReduce",
					"Threshold": 0
				}
			},
			"Name": "ScaleInContainersPending"
		}, {
			"Action": {
				"SimpleScalingPolicyConfiguration": {
					"ScalingAdjustment": -1,
					"CoolDown": 120,
					"AdjustmentType": "CHANGE_IN_CAPACITY"
				}
			},
			"Description": "",
			"Trigger": {
				"CloudWatchAlarmDefinition": {
					"MetricName": "YARNMemoryAvailablePercentage",
					"ComparisonOperator": "GREATER_THAN_OR_EQUAL",
					"Statistic": "AVERAGE",
					"Period": 300,
					"EvaluationPeriods": 1,
					"Unit": "PERCENT",
					"Namespace": "AWS/ElasticMapReduce",
					"Threshold": 75
				}
			},
			"Name": "ScaleInYarnMemoryUtilization"
		}]
	}
EOF
}
