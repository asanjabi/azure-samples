param location string = resourceGroup().location
param logAnalyticsName string
param tags object = {}

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
