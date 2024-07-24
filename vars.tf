variable "rgname" {
  type        = string
  description = "Name rg group"
  default     = "mlops_learning"
}

variable "location" {
  type        = string
  description = "Location of the resources"
  default     = "northeurope"
}

variable "ml" {
  type        = string
  description = "name of Ml workspace"
  default     = "mlterraform24july"
}
variable "tenant_id" {
  type        = string
  description = "The Tenant ID to use for this Key Vault."
  default  = "93f33571-550f-43cf-b09f-cd331338d086"
}
