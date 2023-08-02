resource "azuread_user" "this" {
  count               = var.number_of_users
  user_principal_name = "user${count.index}@${var.domain_name}"
  display_name        = "User ${count.index}"
  mail_nickname       = "user${count.index}"
  password            = var.user_default_password
  usage_location      = "FR"
  depends_on = [
    azuread_group.this
  ]
}

resource "azuread_group_member" "this" {
  count            = var.number_of_users
  group_object_id  = azuread_group.this.id
  member_object_id = azuread_user.this[count.index].id
  depends_on = [
    azuread_user.this,
    azuread_group.this
  ]
}
