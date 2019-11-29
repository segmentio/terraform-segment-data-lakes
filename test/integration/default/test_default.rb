# frozen_string_literal: true

require 'awspec'
require 'aws-sdk'
require 'rhcl'

# Parse and load our terraform manifest into example_main
example_main = Rhcl.parse(File.open('test/test_fixture/main.tf'))

# Load the terraform state file and convert it into a Ruby hash
state_file = 'test/test_fixture/terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate'
tf_state = JSON.parse(File.open(state_file).read)

# Test the Glue resource.
# TODO: This isn't currently supported by awspec
# glue_db_name = example_main['module']['glue']['name']
# describe glue(glue_db_name.to_s) do
#  it { should exist }
#  it { should be_available }
# end

# Test the IAM resource.
iam_role_name = example_main['module']['iam']['name']
describe iam_role(iam_role_name.to_s) do
 it { should exist }
 it { should have_iam_policy('SegmentDataLakePolicy') }

 its('attached_policies.count') { should eq 1 }
 its('resource.tags.count') { should eq 2 }
end
