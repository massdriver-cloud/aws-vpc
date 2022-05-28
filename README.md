# aws-vpc

AWS Virtual Private Network

## Development
### Enabling Pre-commit

This repo includes Terraform pre-commit hooks.

[Install precommmit](https://pre-commit.com/index.html#installation) on your system.

```shell
git init
pre-commit install
```

Terraform hooks will now be run on each commit.

### GitHub Action for Publishing to Massdriver

A github workflow for publishing has been configured in `.github/workflows/publish.yaml`
### Configuring a bundle

`massdriver.yaml` TBD

Build the bundle locally:

```shell
mass bundle build
```

### Misc

#### Other files
* `operator.mdx` TBD
* `schema.stories.json` TBD
