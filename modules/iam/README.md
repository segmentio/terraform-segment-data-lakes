## Required Inputs

The following input variables are required:

### s3\_bucket

Description: Name of the S3 bucket used by the Data Lake.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### glue\_database\_name

Description: Name of the Glue database used by the Data Lake.

Type: `string`

Default: `"segment"`

### name

Description: The name of the role that will be created.

Type: `string`

Default: `"segment-data-lake-role"`

### segment\_aws\_account

Description: ARN of the AWS account used by Segment.

Type: `string`

Default: `"arn:aws:iam::798609480926:root"`

### tags

Description: A map of tags to add to all resources. A vendor=segment tag will be added automatically.

Type: `map`

Default: `<map>`

