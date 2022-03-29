param location string = resourceGroup().location
param databaseName string
param AdminSid string
param AdminSidType string
param AdminLogin string
param logAnalyticsId string

param tags object = {}

resource SqlServer 'Microsoft.Sql/servers@2021-08-01-preview'={
  location: location
  name:  databaseName
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
      principalType: AdminSidType
      sid: AdminSid
      login: AdminLogin
    }
  }
}
