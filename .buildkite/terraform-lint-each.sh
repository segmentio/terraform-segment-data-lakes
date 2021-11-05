#!/bin/bash
set -euo pipefail

yq() {
  docker run -i $(docker build -q - < .buildkite/Dockerfile.yq) "$@"
}

# for each project in atlantis.yaml, use the terraform docker image for the version
# specified by that workspace, on that dir
cat atlantis.yaml | \
  yq -r '.projects[] | [.name, .dir, .terraform_version] | @tsv' | \
  while IFS=$'\t' read -r name dir version; do
    echo "--- lint workspace $name (dir: $dir) (version: $version)"
    # -recursive added in 0.12
    flags=""
    case "$version" in
      0.14.*)
        flags="-recursive"
        ;;
      0.13.*)
        flags="-recursive"
        ;;
      0.12.*)
        flags="-recursive"
        ;;
      0.11.*)
        ;;
      *)
        echo "don't know flags for version $version"
        exit 1
        ;;
    esac
    docker run -v `pwd`/"$dir":/workdir --workdir /workdir hashicorp/terraform:"$version" \
      fmt -check -diff $flags "." || {
        echo '^^^ +++'
        exit 1
      }
    echo '✔️'
  done