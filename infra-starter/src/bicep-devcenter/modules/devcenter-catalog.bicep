targetScope = 'resourceGroup'

param keyVaultName string

@secure()
param gitHubPatSecretName string

param devcenterSettings object

param devcenterName string

resource devcenter 'Microsoft.DevCenter/devcenters@2022-11-11-preview' existing = {
  name: devcenterName
}

// DevCenter Catalog
resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2023-01-01-preview' = [for catalog in devcenterSettings.catalogs: {
  name: '${catalog.name}'
  parent: devcenter
  properties: {
    gitHub: {
      uri: catalog.gitCloneUri
      branch: catalog.branch
      secretIdentifier: 'https://${keyVaultName}.vault.azure.net/secrets/${gitHubPatSecretName}'
      path: catalog.folderPath
    }
  }
}]
