param resourceNamePrefix string

param appInsightsReferenceInfo object = {}
param functionAadAuthenticationSettings object = {}
param logAnalyticsId string
param location string = resourceGroup().location
param hostingSku object
param tags object = {}
param additionalSettings array = []
param roles array = []

var c = json(loadTextContent('constants.json'))

var functionsAppName = take('${resourceNamePrefix}-func', c.constants.functionsMaxNameLength)
var functionStorageName = take('${resourceNamePrefix}stor', c.constants.maxStorageAccountNameLength)
var funcHostingPlanName = take('${resourceNamePrefix}plan', c.constants.appServicePlanMaxNameLength)

output ManagedId string = functionApp.identity.principalId

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: functionStorageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  tags: tags
}

resource storageAccountDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Send_To_LogAnalytics'
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsId

    metrics: [
      {
        enabled: true
        category: 'Transaction'
      }
    ]
  }
}

resource appService 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: funcHostingPlanName
  location: location
  kind: 'functionapp'
  sku: hostingSku
  tags: tags
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsReferenceInfo.name
  scope: resourceGroup(appInsightsReferenceInfo.subscriptionId, appInsightsReferenceInfo.rgName)
}


var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'

var basicSettings = [
  {
    name: 'AzureWebJobsStorage__accountName'
    value: functionStorageName
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: storageAccountConnectionString
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  ((!empty(functionAadAuthenticationSettings)) ? {
    name: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
    value: functionAadAuthenticationSettings.clientId
  } : null)
]

var finalSettings = concat(basicSettings, additionalSettings)

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
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

      netFrameworkVersion: 'V6.0'
    }
  }

  tags: tags
}

resource auth 'Microsoft.Web/sites/config@2021-03-01' = if (!empty(functionAadAuthenticationSettings)) {
  name: 'authsettingsV2'
  parent: functionApp
  properties: {
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
      redirectToProvider: 'azureactivedirectory'
    }
    httpSettings: {
      requireHttps: true
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: functionAadAuthenticationSettings.clientId
          clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
          openIdIssuer: functionAadAuthenticationSettings.OpenIdIssuer
        }
      }
    }
  }
}

resource functionAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsId)) {
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

resource storageBlobDataOwner 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  scope: subscription()
}
resource storageAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(functionStorageName, functionApp.name, storageBlobDataOwner.name, resourceGroup().id)
  properties: {
    roleDefinitionId: storageBlobDataOwner.id
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles: {
  name: guid(functionApp.id, role.principalId, role.roleDefinitionId)
  scope: functionApp
  properties: {
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]
