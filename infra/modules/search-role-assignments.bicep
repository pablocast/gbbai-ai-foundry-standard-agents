@description('Name of the AI Search resource')
param aiSearchName string

@description('Principal ID of the AI project')
param projectPrincipalId string

// Reference to existing AI Search service
resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: aiSearchName
}

// Search Service Contributor role assignment
resource searchContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(projectPrincipalId, '8ebe5a00-799e-43f5-93ac-243d3dce84a7', searchService.id)
  scope: searchService
  properties: {
    principalId: projectPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '8ebe5a00-799e-43f5-93ac-243d3dce84a7')
    principalType: 'ServicePrincipal'
  }
}

// Search Index Data Contributor role assignment
resource searchIndexDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(projectPrincipalId, '7ca78c08-252a-4471-8644-bb5ff32d4ba0', searchService.id)
  scope: searchService
  properties: {
    principalId: projectPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '7ca78c08-252a-4471-8644-bb5ff32d4ba0')
    principalType: 'ServicePrincipal'
  }
}
