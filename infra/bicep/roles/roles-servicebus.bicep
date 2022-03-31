targetScope = 'subscription'

resource dataOwner 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing={
  name: '090c5cfd-751d-490a-894a-3ce6f1109419'
}
@description('Allows for full access to Azure Service Bus resources.')
output DataOwner string = dataOwner.id

resource dataReceiver 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing={
  name: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
}
@description('Allows for receive access to Azure Service Bus resources.')
output DataReceiver string = dataReceiver.id

resource dataSender 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing={
  name: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
}
@description('Allows for receive access to Azure Service Bus resources.')
output DataSender string = dataSender.id


output TypeUser string = 'User'
output TypeGroup string = 'Group'
output TypeSP string = 'ServicePrincipal'
output TypeDevice string = 'Device'
output TypeForeignGroup string = 'ForeignGroup'
