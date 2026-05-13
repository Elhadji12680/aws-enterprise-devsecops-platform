locals {
  project_tags = {
    contact      = "devops@apci.com"
    application  = "Jupiter"
    project      = "UAICEI"
    environment  = terraform.workspace # it refers to my current workspace (dev, prod, stag....)
    creationTime = timestamp()
  }
}