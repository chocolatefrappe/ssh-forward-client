variable "NODE_VERSION" { default = "20" }

target "docker-metadata-action" {}
target "github-metadata-action" {}

target "template" {
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  args = {
    NODE_VERSION = "${NODE_VERSION}"
  }
}

target "default" {
  inherits = [
    "template",
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "dev" {
  inherits = [
    "template",
  ]
  tags = [
    "chocolatefrappe/ssh-proxy-client:local"
  ]
}
