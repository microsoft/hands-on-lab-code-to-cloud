resource "azuread_directory_role" "this" {
  display_name = "Global Reader"
}

resource "azuread_directory_role_assignment" "this" {
  role_id             = azuread_directory_role.this.template_id
  principal_object_id = azuread_group.this.object_id
}

resource "azurerm_role_assignment" "this" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.this.object_id
}
