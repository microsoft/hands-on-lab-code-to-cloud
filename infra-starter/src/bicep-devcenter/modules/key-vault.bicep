@secure()
param githubPat string

param location string

param resourceSuffixLowercase string

param tags object

var keyVaultName = 'kv${resourceSuffixLowercase}'

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv${resourceSuffixLowercase}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: 'bf6ba0e1-6302-4ac7-a62f-2d391e1da162'
        permissions: {
          secrets: [
            'Get'
            'List'
            'Set'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    vaultUri: 'https://${keyVaultName}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

var gitHubPatSecretName = 'GitHubPat'

resource GitHubPatSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: kv
  name: gitHubPatSecretName
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: githubPat
  }
}

output keyVaultName string = kv.name
output gitHubPatSecretName string = GitHubPatSecret.name
