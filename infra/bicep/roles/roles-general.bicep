
targetScope = 'subscription'

resource owner 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing ={
  name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}
output Owner string = owner.id

resource contributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing ={
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}
output Contributor string = contributor.id

resource reader 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing={
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}
output Reader string = reader.id

resource userAccessAdmin 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing={
  name: '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
}
output UserAccessAdmin string = userAccessAdmin.id


output TypeUser string = 'User'
output TypeGroup string = 'Group'
output TypeSP string = 'ServicePrincipal'
output TypeDevice string = 'Device'
output TypeForeignGroup string = 'ForeignGroup'
