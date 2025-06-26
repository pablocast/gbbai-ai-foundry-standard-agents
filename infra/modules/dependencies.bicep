@description('Azure region of the deployment')
param location string

@description('The name of the AI Search resource')
param aiSearchName string

@description('Name of the storage account')
param azureStorageName string

@description('Name of the new Cosmos DB account')
param cosmosDBName string

@description('The AI Search Service full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param aiSearchResourceId string

@description('The AI Storage Account full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param azureStorageAccountResourceId string

@description('The Cosmos DB Account full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param cosmosDBResourceId string

param noZRSRegions array = [
  'southindia'
  'westus'
]

param sku object = contains(noZRSRegions, location) ? {
  name: 'Standard_GRS'
} : {
  name: 'Standard_ZRS'
}

// Variables
var storagePassedIn = !empty(azureStorageAccountResourceId)
var searchPassedIn = !empty(aiSearchResourceId)
var cosmosPassedIn = !empty(cosmosDBResourceId)

var cosmosParts = split(cosmosDBResourceId, '/')
var canaryRegions = [
  'eastus2euap'
  'centraluseuap'
]
var cosmosDbRegion = contains(canaryRegions, location) ? 'westus' : location

var acsParts = split(aiSearchResourceId, '/')
var azureStorageParts = split(azureStorageAccountResourceId, '/')

// Cosmos DB
resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = if (!cosmosPassedIn) {
  name: cosmosDBName
  location: cosmosDbRegion
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    disableLocalAuth: true
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    enableFreeTier: false
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

// AI Search
resource aiSearch 'Microsoft.Search/searchServices@2024-06-01-preview' = if (!searchPassedIn) {
  name: aiSearchName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: false
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    hostingMode: 'default'
    partitionCount: 1
    publicNetworkAccess: 'enabled'
    replicaCount: 1
    semanticSearch: 'disabled'
  }
  sku: {
    name: 'standard'
  }
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = if (!storagePassedIn) {
  name: azureStorageName
  location: location
  kind: 'StorageV2'
  sku: sku
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      virtualNetworkRules: []
    }
    allowSharedKeyAccess: false
  }
}

// Blob Services for Storage Account
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = if (!storagePassedIn) {
  parent: storageAccount
  name: 'default'
}

// Documents Container
resource documentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = if (!storagePassedIn) {
  parent: blobServices
  name: 'documentes'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

// Outputs
output aiSearchName string = searchPassedIn ? acsParts[8] : aiSearchName
output aiSearchID string = searchPassedIn ? resourceId(acsParts[2], acsParts[4], 'Microsoft.Search/searchServices', acsParts[8]) : aiSearch.id
output aiSearchServiceResourceGroupName string = searchPassedIn ? acsParts[4] : resourceGroup().name
output aiSearchServiceSubscriptionId string = searchPassedIn ? acsParts[2] : subscription().subscriptionId

output azureStorageName string = storagePassedIn ? azureStorageParts[8] : azureStorageName
output azureStorageId string = storagePassedIn ? resourceId(azureStorageParts[2], azureStorageParts[4], 'Microsoft.Storage/storageAccounts', azureStorageParts[8]) : storageAccount.id
output azureStorageResourceGroupName string = storagePassedIn ? azureStorageParts[4] : resourceGroup().name
output azureStorageSubscriptionId string = storagePassedIn ? azureStorageParts[2] : subscription().subscriptionId

output cosmosDBName string = cosmosPassedIn ? cosmosParts[8] : cosmosDBName
output cosmosDBId string = cosmosPassedIn ? resourceId(cosmosParts[2], cosmosParts[4], 'Microsoft.DocumentDB/databaseAccounts', cosmosParts[8]) : cosmosDB.id
output cosmosDBResourceGroupName string = cosmosPassedIn ? cosmosParts[4] : resourceGroup().name
output cosmosDBSubscriptionId string = cosmosPassedIn ? cosmosParts[2] : subscription().subscriptionId
