targetScope = 'subscription'

resource storageBlobDataOwner 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing={
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}
@description('Provides full access to Azure Storage blob containers and data, including assigning POSIX access control.')
output Storage_BlobDataOwner string = storageBlobDataOwner.id


output TypeUser string = 'User'
output TypeGroup string = 'Group'
output TypeSP string = 'ServicePrincipal'
output TypeDevice string = 'Device'
output TypeForeignGroup string = 'ForeignGroup'
