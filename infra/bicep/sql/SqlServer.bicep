param location string = resourceGroup().location
param serverName string
param adminSid string
param adminSidType string
param adminLogin string
param roles array = []

param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview'={
  location: location
  name:  serverName
  tags: tags
  identity:{
    type: 'SystemAssigned'
  }
  properties:{
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators:{
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      principalType: adminSidType
      sid: adminSid
      login: adminLogin
    }
  }
}

output serverName string = sqlServer.name

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles :{
  name: guid(sqlServer.id, role.principalId, role.roleDefinitionId)
  scope: sqlServer
  properties:{
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]
