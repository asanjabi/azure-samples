
param planName string
param location string = resourceGroup().location
param sku object
param kind string
param logAnalyticsId string
param tags object = {}
param roles array = []

resource plan 'Microsoft.Web/serverfarms@2021-03-01'={
  name: planName
  location: location
  sku: sku
  kind: kind
  tags: tags
}

resource planDiagnosticsSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsId)){
  name: 'Send_To_LogAnalytics'
  scope: plan
  properties: {
    workspaceId: logAnalyticsId
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles :{
  name: guid(plan.id, role.principalId, role.roleDefinitionId)
  scope: plan
  properties:{
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]
