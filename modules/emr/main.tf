# Creates an EMR cluster that will be used to transform and load events into the Data Lake.
# https://www.terraform.io/docs/providers/aws/r/emr_cluster.html
resource "aws_emr_cluster" "segment_data_lake_emr_cluster" {
  name          = "segment-data-lake"
  release_label = "emr-4.6.0"
  applications  = ["Hadoop", "Hive", "Spark"]

  log_uri = "${var.s3_bucket}/logs"

  ec2_attributes {
    subnet_id                         = "${var.subnet_id}"
    emr_managed_master_security_group = "${var.master_security_group}"
    emr_managed_slave_security_group  = "${var.slave_security_group}"
    instance_profile                  = "${var.instance_profile}"
  }

  service_role = "${var.service_role}"

  master_instance_group {
    instance_type = "m5.xlarge"

    ebs_config {
      size                 = "64"
      type                 = "gp2"
      volumes_per_instance = 1
    }
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 2

    ebs_config {
      size                 = "64"
      type                 = "gp2"
      volumes_per_instance = 1
    }

    autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": 1,
  "MaxCapacity": 4
},
"Rules": [
  {
    "Name": "ScaleOutMemoryPercentage",
    "Description": "Scale out if YARNMemoryAvailablePercentage is less than 15",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": 1,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "LESS_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 15.0,
        "Unit": "PERCENT"
      }
    }
  },
  {
    "Name": "ScaleInMemoryPercentage",
    "Description": "Scale in if YARNMemoryAvailablePercentage is greater than 75",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": -1,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "GREATER_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 75.0,
        "Unit": "PERCENT"
      }
    }
  }
]
}
EOF
  }

  tags = "${local.tags}"
}
