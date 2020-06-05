# Creates an EMR cluster that will be used to transform and load events into the Data Lake.
# https://www.terraform.io/docs/providers/aws/r/emr_cluster.html
resource "aws_emr_cluster" "segment_data_lake_emr_cluster" {
  name          = "${var.cluster_name}"
  release_label = "emr-5.27.0"
  applications  = ["Hadoop", "Hive", "Spark"]

  log_uri = "s3://${var.s3_bucket}/${var.emr_logs_s3_prefix}"

  ec2_attributes {
    subnet_id                         = "${var.subnet_id}"
    emr_managed_master_security_group = "${var.master_security_group}"
    emr_managed_slave_security_group  = "${var.slave_security_group}"
    instance_profile                  = "${var.iam_emr_instance_profile}"
  }

  service_role     = "${var.iam_emr_service_role}"
  autoscaling_role = "${var.iam_emr_autoscaling_role}"

  master_instance_group {
    instance_type = "${var.master_instance_type}"
    name          = "master_group"

    ebs_config {
      size                 = "64"
      type                 = "gp2"
      volumes_per_instance = 1
    }
  }

  core_instance_group {
    instance_type  = "${var.core_instance_type}"
    instance_count = "${var.core_instance_count}"
    name           = "core_group"


    ebs_config {
      size                 = "64"
      type                 = "gp2"
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


  configurations_json = <<EOF
  [
    {
      "Classification": "hive-site",
      "Properties": {
        "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      }
    },
    {
      "Classification": "spark-hive-site",
      "Properties": {
        "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"      }
    }
  ]
EOF


  tags = "${local.tags}"
}

resource "aws_emr_instance_group" "task" {
  name       = "task_group"
  cluster_id = join("", aws_emr_cluster.segment_data_lake_emr_cluster.*.id)

  instance_type  = "${var.task_instance_type}"
  instance_count = "${var.task_instance_count}"

  ebs_config {
    size                 = "64"
    type                 = "gp2"
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