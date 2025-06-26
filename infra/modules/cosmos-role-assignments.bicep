@description('Name of the AI Search resource')
param cosmosDBName string

@description('Principal ID of the AI project')
param projectPrincipalId string

// Reference to existing Cosmos DB account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: cosmosDBName
}

// Cosmos DB Built-in Data Contributor role assignment
resource cosmosRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(projectPrincipalId, 'b24988ac-6180-42a0-ab88-20f7382dd24c', cosmosAccount.id)
  scope: cosmosAccount
  properties: {
    principalId: projectPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalType: 'ServicePrincipal'
  }
}

// Additional DocumentDB Account Contributor role for comprehensive access
resource cosmosAccountContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(projectPrincipalId, '5bd9cd88-fe45-4216-938b-f97437e15450', cosmosAccount.id)
  scope: cosmosAccount
  properties: {
    principalId: projectPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '5bd9cd88-fe45-4216-938b-f97437e15450')
    principalType: 'ServicePrincipal'
  }
}

// Cosmos DB Operator role assignment
resource cosmosDBOperatorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: cosmosAccount
  name: guid(projectPrincipalId,'230815da-be43-4aae-9cb4-875f7bd000aa', cosmosAccount.id)
  properties: {
    principalId: projectPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '230815da-be43-4aae-9cb4-875f7bd000aa')
    principalType: 'ServicePrincipal'
  }
}
