terraform {
  backend "s3" {
    bucket       = "tickerops-tfstate-921499350264"
    key          = "envs/dev/terraform.tfstate"
    region       = "ca-central-1"
    profile      = "tickerops"
    encrypt      = true
    use_lockfile = true
  }
}