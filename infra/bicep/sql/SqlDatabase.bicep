param databaseName string
param location string = resourceGroup().location
param serverName string
param logAnalyticsId string
param sku object
param tags object = {}

var sqlOptions = json(loadTextContent('sql-database-options.json'))

resource databaseServer 'Microsoft.Sql/servers@2021-08-01-preview' existing ={
    name: serverName
}

resource database 'Microsoft.Sql/servers/databases@2021-08-01-preview'={
  name: databaseName
  location: location
  tags: tags
  parent:  databaseServer
  sku: sku
}

resource databaseDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsId)){
  name: 'Send_To_LogAnalytics'
  scope: database
  properties: {
    workspaceId: logAnalyticsId
    logs: sqlOptions.diagnostics.logs.all_logs
    metrics: sqlOptions.diagnostics.metrics.all_metrics
   }
}
