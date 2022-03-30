param location string = resourceGroup().location
param resourcenamePrefix string = uniqueString(resourceGroup().id)
param AdminSid string

@allowed([
  'User'
  'Group'
])
param AdminSidType string
param AdminLogin string

var logAnalyticsName = take('log-${resourcenamePrefix}', 63)
var appInsightsName = take('appi-${resourcenamePrefix}', 255)
var databaseServerName = take('sql-${resourcenamePrefix}', 128)
var databaseName = take('sqldb-${resourcenamePrefix}', 128)
var defaultTags={}

var sqlOptions = json(loadTextContent('../../../infra/bicep/sql/sql-database-options.json'))

module logAnalytics '../../../infra/bicep/logAnalytics.bicep'={
  name: 'logAnalytics'
  params:{
    location:location
    logAnalyticsName:logAnalyticsName
    tags: defaultTags
  }
}

module applicationInsights '../../../infra/bicep/applicationInsights.bicep' = {
  name: 'appInsights'
  params: {
    location:location
    appInsightsName: appInsightsName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: defaultTags
  }
}

module sqlServer '../../../infra/bicep/sql/SqlServer.bicep'={
  name: 'sqlServer'
  params:{
    location: location
    serverName: databaseServerName
    adminSid: AdminSid
    adminSidType: AdminSidType
    adminLogin: AdminLogin
    tags: defaultTags
  }
}

module database '../../../infra/bicep/sql/SqlDatabase.bicep'={
  name: 'database'
  params:{
    databaseName: databaseName
    serverName: sqlServer.outputs.serverName
    location: location
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    sku: sqlOptions.skus.small_serverless
    tags: defaultTags
  }
}
