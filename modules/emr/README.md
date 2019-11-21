## Required Inputs

The following input variables are required:

### instance\_profile

Description: Instance Profile for EC2 instances of the cluster assume this role.

Type: `string`

### s3\_bucket

Description: Name of the S3 bucket used by the Data Lake. The EMR cluster will be configured to store logs in this bucket.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### master\_security\_group

Description: Identifier of the Amazon EC2 EMR-Managed security group for the master node.

Type: `string`

Default: `""`

### slave\_security\_group

Description: Identifier of the Amazon EC2 EMR-Managed security group for the slave nodes.

Type: `string`

Default: `""`

### subnet\_id

Description: VPC subnet id where you want the job flow to launch. Cannot specify the cc1.4xlarge instance type for nodes of a job flow launched in a Amazon VPC.

Type: `string`

Default: `""`

### tags

Description: A map of tags to add to all resources. A vendor=segment tag will be added automatically (which is also used by the IAM policy to provide Segment access to submit jobs).

Type: `map`

Default: `<map>`

