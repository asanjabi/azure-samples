param queueName string
param namespaceName string
param roles array = []

resource sbNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' existing ={
  name: namespaceName
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview'={
  name: queueName
  parent: sbNamespace
  properties:{
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for role in roles :{
  name: guid(queue.id, role.principalId, role.roleDefinitionId)
  scope: queue
  properties:{
    roleDefinitionId: role.roleDefinitionId
    principalId: role.principalId
    principalType: role.principalType
  }
}]
