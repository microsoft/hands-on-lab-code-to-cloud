targetScope = 'subscription'

@secure()
param githubPat string

param resourceNaming object

param devcenterSettings object

var resourceSuffixKebabcase = '${resourceNaming.environment}-${resourceNaming.region}-${resourceNaming.domain}-${resourceNaming.owner}-${resourceNaming.resourceSuffix}'
var resourceSuffixSnackcase = replace(resourceSuffixKebabcase, '-', '_')
var resourceSuffixLowercase = replace(resourceSuffixKebabcase, '-', '')

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceSuffixKebabcase}'
  location: resourceNaming.location
  tags: resourceNaming.tags
}

// Network
module network './modules/network.bicep' = {
  name: 'Microsoft.Network'
  scope: resourceGroup(rg.name)
  params: {
    location: resourceNaming.location
    resourceSuffixKebabcase: resourceSuffixKebabcase
    tags: resourceNaming.tags
  }
}

// Key Vault
module keyVault './modules/key-vault.bicep' = {
  name: 'Microsoft.KeyVault'
  scope: resourceGroup(rg.name)
  params: {
    githubPat: githubPat
    location: resourceNaming.location
    resourceSuffixLowercase: resourceSuffixLowercase
    tags: resourceNaming.tags
  }
}

// Dev Center
module devcenter 'modules/devcenter.bicep' = {
  name: 'Devcenter'
  scope: resourceGroup(rg.name)
  params: {
    devcenterSettings: devcenterSettings
    virtualNetworkName: network.outputs.virtualNetworkName
    resourceSuffixKebabcase: resourceSuffixKebabcase
    resourceSuffixSnackcase: resourceSuffixSnackcase
    location: resourceNaming.location
    tags: resourceNaming.tags
  }
  dependsOn: [
    network
  ]
}

// Dev Center Access Policies to Key Vault
module keyVaultAccess 'modules/key-vault-access-policies.bicep' = {
  name: 'KeyVaultAccessPolicies'
  scope: resourceGroup(rg.name)
  params: {
    resourceSuffixLowercase: resourceSuffixLowercase
    devcenterPrincipalId: devcenter.outputs.devcenterPrincipalId
  }
  dependsOn: [
    keyVault
    devcenter
  ]
}

// Dev Center Catalog
module devcenterCatalog 'modules/devcenter-catalog.bicep' = {
  name: 'DevcenterCatalog'
  scope: resourceGroup(rg.name)
  params: {
    devcenterName: devcenter.outputs.devcenterName
    devcenterSettings: devcenterSettings
    keyVaultName: keyVault.outputs.keyVaultName
    gitHubPatSecretName: keyVault.outputs.gitHubPatSecretName
  }
  dependsOn: [
    keyVaultAccess
    devcenter
  ]
}

// Dev Center Owner Role Assignment
var ownerRoleId = resourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
resource identityRoleAssignOwnerRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: subscription()
  name: guid(ownerRoleId, rg.id)
  properties: {
    roleDefinitionId: ownerRoleId
    principalId: devcenter.outputs.devcenterPrincipalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    devcenter
  ]
}

// Dev Center Project
module project 'modules/devcenter-project.bicep' = {
  name: 'DevcenterProject'
  scope: resourceGroup(rg.name)
  params: {
    devcenterSettings: devcenterSettings
    resourceSuffixKebabcase: resourceSuffixKebabcase
    devcenterId: devcenter.outputs.devcenterId
    location: resourceNaming.location
    tags: resourceNaming.tags
  }
  dependsOn: [
    network
    devcenter
  ]
}
