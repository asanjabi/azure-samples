param namespaceName string
param location string = resourceGroup().location
param logAnalyticsId string
param tags object = {}
param roles array = []

var sbOptions = json(loadTextContent('./servicebus-options.json'))


resource namespace 'Microsoft.ServiceBus/namespaces@2021-11-01'={
  location: location
  name: namespaceName
  sku:{
    name:'Standard'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    disableLocalAuth:true

  }
  tags: tags
}

output NamespaceName string = namespace.name


resource sbDiagnosticsSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsId)){
  name: 'Send_To_LogAnalytics'
  scope: namespace
  properties: {
    workspaceId: logAnalyticsId
    logs: sbOptions.diagnostics.logs.all_logs
    metrics: sbOptions.diagnostics.metrics.all_metrics
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles :{
  name: guid(namespace.id, role.principalId, role.roleDefinitionId)
  scope: namespace
  properties:{
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]
