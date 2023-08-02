resource "azuread_group" "this" {
  display_name       = var.user_group_name
  owners             = [data.azuread_client_config.current.object_id]
  security_enabled   = true
  assignable_to_role = true
}
