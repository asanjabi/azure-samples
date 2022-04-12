param location string = resourceGroup().location
param storageAccountName string
param logAnalyticsId string
param tags object = {}
param roles array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
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

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles :{
  name: guid(storageAccount.id, role.principalId, role.roleDefinitionId)
  scope: storageAccount
  properties:{
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]

output storageAccountReferenceInfo object = {
  'name': storageAccount.name
  'rgName': resourceGroup().name
  'subscriptionId': subscription().subscriptionId
  'apiVersion': storageAccount.apiVersion
}
