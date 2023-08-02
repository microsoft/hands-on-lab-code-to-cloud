targetScope = 'resourceGroup'

param resourceSuffixKebabcase string

param location string

param tags object

// Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'vnet-${resourceSuffixKebabcase}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: securityGroup.id
          }
        }
      }
    ]
  }
  tags: tags
}

// Security Group
resource securityGroup 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'nsg-${resourceSuffixKebabcase}'
  location: location
  properties: {
    securityRules: []
  }
  tags: tags
}

output virtualNetworkName string = virtualNetwork.name
