.PHONY: fmt lint docs install test

# TODO: Use the same targets on CI, so we don't duplicate the commands and configuration.

fmtchk:
	terraform fmt -recursive

lint:
	tflint --disable-rule=terraform_deprecated_interpolation ./modules/glue
	tflint --disable-rule=terraform_deprecated_interpolation ./modules/iam
	tflint --disable-rule=terraform_deprecated_interpolation ./modules/emr

docs:
	terraform-docs markdown document ./modules/glue > ./modules/glue/README.md
	terraform-docs markdown document ./modules/iam > ./modules/iam/README.md
	terraform-docs markdown document ./modules/emr > ./modules/emr/README.md

install:
	bundle install --path vendor/bundle

# This requires AWS credentials to be provided, e.g. with aws-okta you can run: `aws-okta exec dev-write -- make test`
test:
	bundle exec kitchen converge
	bundle exec kitchen verify
	bundle exec kitchen destroy
