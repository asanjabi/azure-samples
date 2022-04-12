param location string = resourceGroup().location
param resourceNamePrefix string = uniqueString(resourceGroup().id)

@secure()
param functionAadAuthenticationSettings object = {}

var defaultTags={}

var c = json(loadTextContent('constants.json'))

var logAnalyticsName = take('log-${resourceNamePrefix}', c.constants.logAnalyticsMaxNameLength)
var appInsightsName = take('appi-${resourceNamePrefix}', c.constants.appInsightsMaxNameLength)
var webSiteStorageName = take('web${resourceNamePrefix}str', c.constants.maxStorageAccountNameLength)

module logAnalytics 'logAnalytics.bicep'={
  name: 'logAnalytics'
  params:{
    location:location
    logAnalyticsName:logAnalyticsName
    tags: defaultTags
  }
}

module applicationInsights 'applicationInsights.bicep' = {
  name: 'appInsights'
  params: {
    location:location
    appInsightsName: appInsightsName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: defaultTags
  }
}


module websiteStorage 'storage.bicep' ={
  name: 'websiteStorage'
  params:{
    location: location
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    storageAccountName: webSiteStorageName
  }
}

var serverlessFunctionsHosting = {
  'name': 'Y1'
  'tier': 'Dynamic'
  'size': 'Y1'
  'family': 'Y'
}

module function1 'function.bicep'={
  name: 'function1'
  params:{
    location: location
    resourceNamePrefix: 'f1${resourceNamePrefix}'
    functionAadAuthenticationSettings: functionAadAuthenticationSettings
    appInsightsReferenceInfo: applicationInsights.outputs.applicationInsightsReferenceInfo
    hostingSku: serverlessFunctionsHosting
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
  }
}

module signalRFunction 'function.bicep'={
  name: 'signalRFunction'
  params:{
    location: location
    resourceNamePrefix: 'signalr${resourceNamePrefix}'
    hostingSku: serverlessFunctionsHosting
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    functionAadAuthenticationSettings: functionAadAuthenticationSettings
    appInsightsReferenceInfo: applicationInsights.outputs.applicationInsightsReferenceInfo
  }
}
