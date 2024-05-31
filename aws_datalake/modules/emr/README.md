## Requirements

No requirements.

## Providers

The following providers are used by this module:

- aws

## Required Inputs

The following input variables are required:

### iam\_emr\_autoscaling\_role

Description: Name of the EMR autoscaling role

Type: `string`

### iam\_emr\_instance\_profile

Description: Name of the EMR EC2 instance profile

Type: `string`

### iam\_emr\_service\_role

Description: Name of the EMR service role

Type: `string`

### s3\_bucket

Description: Name of the S3 bucket used by the Data Lake. The EMR cluster will be configured to store logs in this bucket.

Type: `string`

### subnet\_id

Description: VPC subnet id where you want the job flow to launch. Cannot specify the cc1.4xlarge instance type for nodes of a job flow launched in a Amazon VPC.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### cluster\_name

Description: Name of the EMR cluster that the module creates

Type: `string`

Default: `"segment-data-lake"`

### emr\_cluster\_version

Description: Version of emr cluster

Type: `string`

Default: `"6.5.0"`

### additional\_applications

Description: List of applications to install on the EMR cluster, besides Hadoop, Hive, and Spark.

Type: `list(string)`

Default: `[]`

### key\_name

Description: Amazon EC2 key pair that can be used to ssh to the master node as the user called hadoop.

Type: `string`

Default: `null`

### core\_instance\_count

Description: Number of Core Nodes

Type: `string`

Default: `"2"`

### core\_instance\_max\_count

Description: Max number of Core Nodes used on autoscale

Type: `string`

Default: `"4"`

### core\_instance\_type

Description: EC2 Instance Type for Core Nodes

Type: `string`

Default: `"m5.xlarge"`

### emr\_logs\_s3\_prefix

Description: Prefix for writing EMR cluster logs to S3. Make sure to include a trailing slash (/) when setting this.

Type: `string`

Default: `"logs/"`

### master\_instance\_type

Description: EC2 Instance Type for Master

Type: `string`

Default: `"m5.xlarge"`

### master\_security\_group

Description: Identifier of the Amazon EC2 EMR-Managed security group for the master node.

Type: `string`

Default: `""`

### additional\_master\_security\_groups

Description: String containing a comma separated list of additional Amazon EC2 security group IDs for the master node.

Type: `string`

Default: `""`

### slave\_security\_group

Description: Identifier of the Amazon EC2 EMR-Managed security group for the slave nodes.

Type: `string`

Default: `""`

### additional\_slave\_security\_groups

Description: String containing a comma separated list of additional Amazon EC2 security group IDs for the slave nodes as a comma separated string.

Type: `string`

Default: `""`

### tags

Description: A map of tags to add to all resources. A vendor=segment tag will be added automatically (which is also used by the IAM policy to provide Segment access to submit jobs).

Type: `map`

Default: `{}`

### task\_instance\_count

Description: Number of instances of Task Nodes

Type: `string`

Default: `"2"`

### task\_instance\_max\_count

Description: Max number of Task Nodes used on autoscale

Type: `string`

Default: `"4"`

### task\_instance\_type

Description: EC2 Instance Type for Task Nodes

Type: `string`

Default: `"m5.xlarge"`

### ebs\_size

Description: Volume size, in gibibytes (GiB)

Type: `string`

Default: `"64"`

### ebs\_type

Description: Volume type. Valid options are gp3, gp2, io1, standard, st1 and sc1.

Type: `string`

Default: `"gp2"`

## Outputs

The following outputs are exported:

### cluster\_id

Description: n/a

