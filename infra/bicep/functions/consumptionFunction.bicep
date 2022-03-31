param location string = resourceGroup().location
param namePrefix string
param logAnalyticsId string
param appInsightsInstrumentationKey string
param tags object = {}
param roles array = []

var functionsOptions = json(loadTextContent('functions-options.json'))
var stotrageOptions = json(loadTextContent('../storage/storage-options.json'))
var appserviceOptions= json(loadTextContent('../appservice/appservice-options.json'))

var functionsAppName = take('func-${namePrefix}', functionsOptions.constants.functionsMaxNameLength)
var functionStorageName = take('stfunc${namePrefix}', stotrageOptions.constants.maxStorageAccountNameLength)
var funcHostingPlanName = take('plan${namePrefix}', appserviceOptions.constants.appServicePlanMaxNameLength)

module functionApp './functionApp.bicep'={
  name: '${functionsAppName}-consumption'

  params:{
    functionsAppName: functionsAppName
    functionsHostingPlanName: funcHostingPlanName
    functionsAppStorageName: functionStorageName
    hostingSku: functionsOptions.skus.severless_functions
    logAnalyticsId: logAnalyticsId
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    location: location
    roles: roles
    tags: tags
  }
}

output ManagedId string = functionApp.outputs.ManagedId
