param functionsHostingPlanName string
param functionsAppName string
param functionsAppStorageName string
param appInsightsInstrumentationKey string
param logAnalyticsId string
param location string = resourceGroup().location
param hostingSku object
param tags object = {}
param additionalSettings array = []
param roles array = []

output ManagedId string = functionApp.identity.principalId

module storageAccount '../storage/storage.bicep' = {
  name: functionsAppStorageName
  params: {
    storageAccountName: functionsAppStorageName
    location: location
    logAnalyticsId: logAnalyticsId
    tags: tags
  }
}

resource appService 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: functionsHostingPlanName
  location: location
  kind: 'functionapp'
  sku: hostingSku
  tags: tags
}

var basicSettings = [
  {
    name: 'AzureWebJobsStorage'
    value: storageAccount.outputs.storageAccountConnectionString
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: storageAccount.outputs.storageAccountConnectionString
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: 'InstrumentationKey=${appInsightsInstrumentationKey}'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~3'
  }
]

var finalSettings = concat(basicSettings, additionalSettings)

resource functionApp 'Microsoft.Web/sites@2021-01-01' = {
  name: functionsAppName
  location: location
  kind: 'functionapp'
  dependsOn: [
    storageAccount
  ]

  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appService.id
    siteConfig: {
      appSettings: finalSettings
    }
  }
  tags: tags
}

resource functionAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsId)){
  name: 'Send_To_LogAnalytics'
  scope: functionApp
  properties: {
    workspaceId: logAnalyticsId
    logs: [
      {
        enabled: true
        category: 'FunctionAppLogs'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles :{
  name: guid(functionApp.id, role.principalId, role.roleDefinitionId)
  scope: functionApp
  properties:{
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]
