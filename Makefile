.PHONY: fmt

# TODO: Use the same targets on CI, so we don't duplicate the commands and configuration.

fmt:
	terraform fmt -recursive

lint:
	tflint ./modules/glue
	tflint ./modules/iam
	tflint ./modules/emr

docs:
	terraform-docs markdown document ./modules/glue > ./modules/glue/README.md
	terraform-docs markdown document ./modules/iam > ./modules/iam/README.md
	terraform-docs markdown document ./modules/emr > ./modules/emr/README.md
