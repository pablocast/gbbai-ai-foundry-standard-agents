param accountName string
param location string
param models array

// AI Services Account
resource aiServicesAccount 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: accountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: accountName
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// Model Deployments - Sequential deployment with dependencies
resource modelDeployment0 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = if (length(models) > 0) {
  parent: aiServicesAccount
  name: models[0].name
  sku: {
    capacity: models[0].capacity
    name: models[0].skuName
  }
  properties: {
    model: {
      name: models[0].name
      format: models[0].format
      version: models[0].version
    }
  }
}

resource modelDeployment1 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = if (length(models) > 1) {
  parent: aiServicesAccount
  name: models[1].name
  sku: {
    capacity: models[1].capacity
    name: models[1].skuName
  }
  properties: {
    model: {
      name: models[1].name
      format: models[1].format
      version: models[1].version
    }
  }
  dependsOn: [
    modelDeployment0
  ]
}

// Outputs
output accountName string = accountName
output accountID string = aiServicesAccount.id
output accountTarget string = aiServicesAccount.properties.endpoint
output accountPrincipalId string = aiServicesAccount.identity.principalId
output deployedModels array = [for (model, index) in models: {
  name: model.name
  deploymentName: model.name
  format: model.format
  version: model.version
}]
