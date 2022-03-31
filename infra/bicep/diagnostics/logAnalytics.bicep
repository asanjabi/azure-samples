param location string = resourceGroup().location
param logAnalyticsName string
param tags object = {}
param roles array = []

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01'={
  name: logAnalyticsName
  location: location
  tags: tags
}

resource logAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Send_To_LogAnalytics'
  scope: logAnalytics
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        enabled: true
        category: 'Audit'
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

output logAnalyticsId string = logAnalytics.id
output rgName string = resourceGroup().name
output laName string = logAnalytics.name
output la object = logAnalytics

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles :{
  name: guid(logAnalytics.id, role.principalId, role.roleDefinitionId)
  scope: logAnalytics
  properties:{
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]
