variable "user_group_name" {
  description = "The name of the user group"
  type        = string
  default     = "dev-box-user-group"
}

variable "domain_name" {
  description = "The name of the Azure AD tenant"
  type        = string
  default     = "parisbuild2023outlook.onmicrosoft.com"
}

variable "user_default_password" {
  description = "The user default password inside the Azure AD tenant"
  type        = string
  default     = "Password123@"
}

variable "number_of_users" {
  description = "The number of users to create"
  type        = number
  default     = 20
}
