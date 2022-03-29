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
var defaultTags={}

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

module sqlServer '../../../infra/bicep/SqlServer.bicep'={
  name: 'sqlServer'
  params:{
    location: location
    databaseName: databaseServerName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    AdminSid: AdminSid
    AdminSidType: AdminSidType
    AdminLogin: AdminLogin
    tags: defaultTags
  }
}
