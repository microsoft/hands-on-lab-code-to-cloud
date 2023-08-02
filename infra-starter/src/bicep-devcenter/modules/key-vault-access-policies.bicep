param devcenterPrincipalId string
param resourceSuffixLowercase string

resource devCenterKeyVaultAccess 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'kv${resourceSuffixLowercase}/add'
  properties: {
    accessPolicies: [
      {
        objectId: devcenterPrincipalId
        permissions: {
          secrets: [
            'Get'
            'List'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}
