param location string = resourceGroup().location
param serverName string
param adminSid string
param adminSidType string
param adminLogin string

param tags object = {}

resource SqlServer 'Microsoft.Sql/servers@2021-08-01-preview'={
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

output serverName string = SqlServer.name
