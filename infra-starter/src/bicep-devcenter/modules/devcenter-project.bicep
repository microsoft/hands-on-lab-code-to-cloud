param resourceSuffixKebabcase string

param devcenterSettings object

param location string

param tags object

param devcenterId string

// DevCenter Project
resource project 'Microsoft.DevCenter/projects@2022-11-11-preview' = {
  name: 'prj-${resourceSuffixKebabcase}'
  location: location
  properties: {
    devCenterId: devcenterId
    description: devcenterSettings.project.description
  }
  tags: tags
}

// Project pools
resource projectPools 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = [for (pool, index) in devcenterSettings.project.pools: {
  parent: project
  name: 'pool-${pool.devBoxDefinitionName}-${index}'
  location: location
  tags: tags
  properties: {
    devBoxDefinitionName: pool.devBoxDefinitionName
    networkConnectionName: 'default'
    licenseType: 'Windows_Client'
    localAdministrator: pool.administrator
  }
}]

// Project pools schedules
resource projectPoolsSchedules 'Microsoft.DevCenter/projects/pools/schedules@2023-01-01-preview' = [for (pool, index) in devcenterSettings.project.pools: {
  parent: projectPools[index]
  name: 'default' // Can't be changed for now
  properties: {
    type: 'StopDevBox'
    frequency: 'Daily'
    time: '20:00'
    timeZone: 'Europe/Paris'
    state: 'Enabled'
  }
  dependsOn: [
    projectPools
  ]
}]

// Project Environment Types
resource projectEnvironmentTypes 'Microsoft.DevCenter/projects/environmentTypes@2023-01-01-preview' = [for (envType, index) in devcenterSettings.environmentTypes: {
  parent: project
  name: envType
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    deploymentTargetId: '/subscriptions/${subscription().subscriptionId}'
    status: 'Enabled'
    creatorRoleAssignment: {
      roles: {
        '45d50f46-0b78-4001-a660-4198cbe8cd05': {} // DevCenter Dev Box User
      }
    }
  }
}]

output projectName string = project.name
