targetScope = 'resourceGroup'

param resourceSuffixKebabcase string

param resourceSuffixSnackcase string

param devcenterSettings object

param virtualNetworkName string

param location string

param tags object

var image = {
  'win-11-ent-os-opt': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
  'win-11-ent-m365-apps': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
  'win-11-ent-m365-apps-vs-2022': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

var compute = {
  '4-vcpu-16gb-mem': 'general_a_4c16gb_v1'
  '8-vcpu-32gb-mem': 'general_a_8c32gb_v1'
}

var storage = {
  '256gb-ssd': 'ssd_256gb'
  '512gb-ssd': 'ssd_512gb'
  '1024gb-ssd': 'ssd_1024gb'
}

// Network Connection
resource networkConnection 'Microsoft.DevCenter/networkconnections@2022-11-11-preview' = {
  name: 'con-${resourceSuffixKebabcase}'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: virtualNetwork.properties.subnets[0].id
    networkingResourceGroupName: 'NI_networkconnections_con_${resourceSuffixSnackcase}_name_${location}'
  }
  tags: tags
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup()
}

// DevCenter
resource devcenter 'Microsoft.DevCenter/devcenters@2022-11-11-preview' = {
  name: 'devc-${resourceSuffixKebabcase}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
  tags: tags
}

// DevCenter Attached Networks
resource attachedNetworks 'Microsoft.DevCenter/devcenters/attachednetworks@2022-11-11-preview' = {
  parent: devcenter
  name: 'default'
  properties: {
    networkConnectionId: networkConnection.id
  }
}

// DevBox Definitions
resource devBoxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2022-11-11-preview' = [for definition in devcenterSettings.definitions: {
  parent: devcenter
  name: definition.name
  location: location
  properties: {
    imageReference: {
      id: '${devcenter.id}/galleries/default/images/${image[definition.image]}'
    }
    sku: {
      name: compute[definition.compute]
    }
    osStorageType: storage[definition.storage]
  }
  dependsOn: [
    attachedNetworks
  ]
}]

// DevCenter Environment Types
resource environmentType 'Microsoft.DevCenter/devcenters/environmentTypes@2023-01-01-preview' = [for envTypes in devcenterSettings.environmentTypes: {
  parent: devcenter
  name: envTypes
  properties: {}
}]

output devcenterId string = devcenter.id
output devcenterName string = devcenter.name
output devcenterPrincipalId string = devcenter.identity.principalId
