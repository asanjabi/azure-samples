param location string = resourceGroup().location
param resourcenamePrefix string = uniqueString(resourceGroup().id)
param AdminSid string

@allowed([
  'User'
  'Group'
])
param AdminSidType string
param AdminLogin string

var sqlOptions = json(loadTextContent('../../../infra/bicep/sql/sql-database-options.json'))
var diagnosticsOptions = json(loadTextContent('../../../infra/bicep/diagnostics/diagnostics-options.json'))
var sbOptions = json(loadTextContent('../../../infra/bicep/servicebus/servicebus-options.json'))

var logAnalyticsName = take('log-${resourcenamePrefix}', diagnosticsOptions.constants.logAnalyticsMaxNameLength)
var appInsightsName = take('appi-${resourcenamePrefix}', diagnosticsOptions.constants.appInsightsMaxNameLength)
var databaseServerName = take('sql-${resourcenamePrefix}', sqlOptions.constants.maxServerNameLength)
var databaseName = take('sqldb-${resourcenamePrefix}', sqlOptions.constants.maxDatabaseNameLength)
var sbNSName = take('sb-${resourcenamePrefix}', sbOptions.constants.servicebusNamespaceMaxLength)

var defaultTags={}


module logAnalytics '../../../infra/bicep/diagnostics/logAnalytics.bicep'={
  name: 'logAnalytics'
  params:{
    location:location
    logAnalyticsName:logAnalyticsName
    tags: defaultTags
  }
}

module applicationInsights '../../../infra/bicep/diagnostics/applicationInsights.bicep' = {
  name: 'appInsights'
  params: {
    location:location
    appInsightsName: appInsightsName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: defaultTags
  }
}

module sqlServer '../../../infra/bicep/sql/SqlServer.bicep'={
  name: 'sqlServer'
  params:{
    location: location
    serverName: databaseServerName
    adminSid: AdminSid
    adminSidType: AdminSidType
    adminLogin: AdminLogin
    tags: defaultTags
  }
}

module database '../../../infra/bicep/sql/SqlDatabase.bicep'={
  name: 'database'
  params:{
    databaseName: databaseName
    serverName: sqlServer.outputs.serverName
    location: location
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    sku: sqlOptions.skus.small_serverless
    tags: defaultTags
  }
}

module senderFunc '../../../infra/bicep/functions/consumptionFunction.bicep'={
  name: 'senderFunc'
  params:{
    namePrefix: 'sender${resourcenamePrefix}'
    location: location
    appInsightsInstrumentationKey: applicationInsights.outputs.appInsightsInstrumentationKey
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: defaultTags
  }
}

module receiverFunc '../../../infra/bicep/functions/consumptionFunction.bicep'={
  name: 'receiverFunc'
  params:{
    namePrefix: 'receiver${resourcenamePrefix}'
    location: location
    appInsightsInstrumentationKey: applicationInsights.outputs.appInsightsInstrumentationKey
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: defaultTags
  }
}

module sbNameSpace '../../../infra/bicep/servicebus/servicebus-namespace.bicep'={
  name: '${sbNSName}-deployment'
  params: {
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    namespaceName: sbNSName
    location: location
  }
}

module queueRoles '../../../infra/bicep/roles/roles-servicebus.bicep'={
  name: 'queuroles'
  scope: subscription()
}

var QueueRoleAssignments = [
  {
    roleDefinitionId: queueRoles.outputs.DataSender
    principalId: senderFunc.outputs.ManagedId
    principalType: queueRoles.outputs.TypeSP
  }
  {
    roleDefinitionId: queueRoles.outputs.DataReceiver
    principalId: receiverFunc.outputs.ManagedId
    principalType: queueRoles.outputs.TypeSP
  }
  {
    roleDefinitionId: queueRoles.outputs.DataOwner
    principalId: AdminSid
    principalType: AdminSidType
  }
]

module sbQueue1 '../../../infra/bicep/servicebus/servicebus-queue.bicep'={
  name: 'queue1-deployment'
  params: {
    namespaceName: sbNameSpace.outputs.NamespaceName
    queueName: 'queue1'
    roles: QueueRoleAssignments
  }
}

module sbQueue2 '../../../infra/bicep/servicebus/servicebus-queue.bicep'={
  name: 'queue2-deployment'
  params: {
    namespaceName: sbNameSpace.outputs.NamespaceName
    queueName: 'queue2'
    roles: QueueRoleAssignments
  }
}
