targetScope = 'resourceGroup'

// Parameters
@description('The Azure region where your AI Foundry resource and project will be created.')
@allowed([
  'australiaeast'
  'canadaeast'
  'eastus'
  'eastus2'
  'francecentral'
  'japaneast'
  'koreacentral'
  'norwayeast'
  'polandcentral'
  'southindia'
  'swedencentral'
  'switzerlandnorth'
  'uaenorth'
  'uksouth'
  'westus'
  'westus3'
  'westeurope'
  'southeastasia'
])
param location string = 'eastus'

@description('The name of the Azure AI Foundry resource.')
@maxLength(9)
param aiServices string = 'foundy'

@description('Name for your project resource.')
param firstProjectName string = 'project'

@description('This project will be a sub-resource of your account')
param projectDescription string = 'some description'

@description('The display name of the project')
param displayName string = 'project'

@description('Array of models to deploy')
param models array = [
  {
    name: 'gpt-4o'
    format: 'OpenAI'
    version: '2024-05-13'
    skuName: 'GlobalStandard'
    capacity: 1
  }
  {
    name: 'gpt-4.1'
    format: 'OpenAI'
    version: '2024-11-20'
    skuName: 'GlobalStandard'
    capacity: 1
  }
  {
    name: 'text-embedding-3-large'
    format: 'OpenAI'
    version: '1'
    skuName: 'Standard'
    capacity: 1
  }
]

@description('The AI Search Service full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param aiSearchResourceId string = ''

@description('The AI Storage Account full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param azureStorageAccountResourceId string = ''

@description('The Cosmos DB Account full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param azureCosmosDBAccountResourceId string = ''

param projectCapHost string = 'caphostproj'
param accountCapHost string = 'caphostacc'
param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')

// Variables
var uniqueSuffix = substring(uniqueString('${resourceGroup().id}-${deploymentTimestamp}'), 0, 4)
var accountName = toLower('${aiServices}${uniqueSuffix}')
var projectName = toLower('${firstProjectName}${uniqueSuffix}')
var cosmosDBName = toLower('${uniqueSuffix}cosmosdb')
var aiSearchName = toLower('${uniqueSuffix}search')
var azureStorageName = toLower('${uniqueSuffix}storage')

var storagePassedIn = !empty(azureStorageAccountResourceId)
var searchPassedIn = !empty(aiSearchResourceId)
var cosmosPassedIn = !empty(azureCosmosDBAccountResourceId)

var acsParts = split(aiSearchResourceId, '/')
var aiSearchServiceSubscriptionId = searchPassedIn ? acsParts[2] : subscription().subscriptionId
var aiSearchServiceResourceGroupName = searchPassedIn ? acsParts[4] : resourceGroup().name

var cosmosParts = split(azureCosmosDBAccountResourceId, '/')
var cosmosDBSubscriptionId = cosmosPassedIn ? cosmosParts[2] : subscription().subscriptionId
var cosmosDBResourceGroupName = cosmosPassedIn ? cosmosParts[4] : resourceGroup().name

var storageParts = split(azureStorageAccountResourceId, '/')
var azureStorageSubscriptionId = storagePassedIn ? storageParts[2] : subscription().subscriptionId
var azureStorageResourceGroupName = storagePassedIn ? storageParts[4] : resourceGroup().name

// Module deployments
module dependencies 'modules/dependencies.bicep' = {
  name: 'dependencies-${accountName}-${uniqueSuffix}-deployment'
  params: {
    location: location
    azureStorageName: azureStorageName
    aiSearchName: aiSearchName
    cosmosDBName: cosmosDBName
    aiSearchResourceId: aiSearchResourceId
    azureStorageAccountResourceId: azureStorageAccountResourceId
    cosmosDBResourceId: azureCosmosDBAccountResourceId
  }
}

module aiServices_module 'modules/ai-services.bicep' = {
  name: 'ai-${accountName}-${uniqueSuffix}-deployment'
  params: {
    accountName: accountName
    location: location
    models: models
  }
  dependsOn: [
    dependencies
  ]
}

module aiProject 'modules/ai-project.bicep' = {
  name: 'ai-${projectName}-${uniqueSuffix}-deployment'
  params: {
    projectName: projectName
    projectDescription: projectDescription
    displayName: displayName
    location: location
    aiSearchName: dependencies.outputs.aiSearchName
    aiSearchServiceResourceGroupName: dependencies.outputs.aiSearchServiceResourceGroupName
    aiSearchServiceSubscriptionId: dependencies.outputs.aiSearchServiceSubscriptionId
    cosmosDBName: dependencies.outputs.cosmosDBName
    cosmosDBSubscriptionId: dependencies.outputs.cosmosDBSubscriptionId
    cosmosDBResourceGroupName: dependencies.outputs.cosmosDBResourceGroupName
    azureStorageName: dependencies.outputs.azureStorageName
    azureStorageSubscriptionId: dependencies.outputs.azureStorageSubscriptionId
    azureStorageResourceGroupName: dependencies.outputs.azureStorageResourceGroupName
    accountName: aiServices_module.outputs.accountName
  }
}

module storageRoleAssignments 'modules/storage-role-assignments.bicep' = {
  name: 'storage-${azureStorageName}-${uniqueSuffix}-deployment'
  scope: resourceGroup(azureStorageSubscriptionId, azureStorageResourceGroupName)
  params: {
    azureStorageName: dependencies.outputs.azureStorageName
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
}

module cosmosRoleAssignments 'modules/cosmos-role-assignments.bicep' = {
  name: 'cosmos-account-ra-${uniqueSuffix}-deployment'
  scope: resourceGroup(cosmosDBSubscriptionId, cosmosDBResourceGroupName)
  params: {
    cosmosDBName: dependencies.outputs.cosmosDBName
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
}

module searchRoleAssignments 'modules/search-role-assignments.bicep' = {
  name: 'ai-search-ra-${uniqueSuffix}-deployment'
  scope: resourceGroup(aiSearchServiceSubscriptionId, aiSearchServiceResourceGroupName)
  params: {
    aiSearchName: dependencies.outputs.aiSearchName
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
}

module capabilityHostConfig 'modules/capability-host.bicep' = {
  name: 'capabilityHost-configuration-${uniqueSuffix}-deployment'
  params: {
    accountName: aiServices_module.outputs.accountName
    projectName: aiProject.outputs.projectName
    cosmosDBConnection: aiProject.outputs.cosmosDBConnection
    azureStorageConnection: aiProject.outputs.azureStorageConnection
    aiSearchConnection: aiProject.outputs.aiSearchConnection
    projectCapHost: projectCapHost
    accountCapHost: accountCapHost
  }
}

module storageContainers 'modules/storage-containers.bicep' = {
  name: 'storage-containers-${uniqueSuffix}-deployment'
  scope: resourceGroup(azureStorageSubscriptionId, azureStorageResourceGroupName)
  params: {
    aiProjectPrincipalId: aiProject.outputs.projectPrincipalId
    storageName: dependencies.outputs.azureStorageName
    workspaceId: aiProject.outputs.projectWorkspaceIdGuid
  }
}

module cosmosDetailedRoleAssignments 'modules/cosmos-detailed-roles.bicep' = {
  name: 'cosmos-ra-${uniqueSuffix}-deployment'
  scope: resourceGroup(cosmosDBSubscriptionId, cosmosDBResourceGroupName)
  params: {
    cosmosAccountName: dependencies.outputs.cosmosDBName
    projectWorkspaceId: aiProject.outputs.projectWorkspaceIdGuid
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
}

// Outputs for environment variables
output PROJECT_ENDPOINT string = aiServices_module.outputs.accountTarget
output MODEL_DEPLOYMENTS array = aiServices_module.outputs.deployedModels
output AZURE_SEARCH_ENDPOINT string = 'https://${dependencies.outputs.aiSearchName}.search.windows.net'
output AZURE_OPENAI_ENDPOINT string = aiServices_module.outputs.accountTarget

// Primary model deployment name (first model for backward compatibility)
output MODEL_DEPLOYMENT_NAME string = models[0].name

// Individual model deployment names for easy access
// Note: These rely on the models array order matching the parameter configuration
output GPT_4O_DEPLOYMENT string = length(models) > 0 ? models[0].name : 'gpt-4o'
output GPT_41_DEPLOYMENT string = length(models) > 1 ? models[1].name : 'gpt-4.1'
output TEXT_EMBEDDING_DEPLOYMENT string = length(models) > 2 ? models[2].name : 'text-embedding-3-large'

// Additional useful outputs
output RESOURCE_GROUP_NAME string = resourceGroup().name
output AI_PROJECT_NAME string = aiProject.outputs.projectName
output AI_SERVICES_NAME string = aiServices_module.outputs.accountName
output AZURE_SEARCH_SERVICE_NAME string = dependencies.outputs.aiSearchName
output COSMOS_DB_NAME string = dependencies.outputs.cosmosDBName
output STORAGE_ACCOUNT_NAME string = dependencies.outputs.azureStorageName
