# <img src="./utils/media/ai_foundry.png" alt="Azure Foundry" style="width:80px;height:30px;"/> AI Foundry Standard Agents

This project includes automated scripts to set up an Standard Azure AI Foundry Agent.

Standard Agent Setup offers enterprise-grade security, compliance, and control. This configuration uses customer-managed, single-tenant resources to store agent state and ensures all data remains within your control.

For more details on the standard agent setup, see the [standard agent setup concept page.](https://learn.microsoft.com/en-us/azure/ai-services/agents/concepts/standard-agent-setup)

## Quick Start

1. **Deploy the infrastructure:**
   ```bash
   azd up
   ```

2. **Set up environment variables:**
   ```bash
   # For bash/Linux/macOS
   source ./infra/scripts/set-env.sh
   
   # For PowerShell/Windows
   .\infra\scripts\set-env.ps1
   ```

3. **Use the .env file in your application:**
   The scripts automatically create a `.env` file with all necessary environment variables.

## Environment Variables

After deployment, the following environment variables will be available:

### Core Variables
- `PROJECT_ENDPOINT` - AI Foundry project endpoint
- `MODEL_DEPLOYMENT_NAME` - Primary model deployment name
- `AZURE_SEARCH_ENDPOINT` - Azure AI Search service endpoint
- `AZURE_OPENAI_ENDPOINT` - Azure OpenAI service endpoint

### Model Deployments
- `GPT_4O_DEPLOYMENT` - GPT-4o model deployment name
- `GPT_41_DEPLOYMENT` - GPT-4.1 model deployment name  
- `TEXT_EMBEDDING_DEPLOYMENT` - Text embedding model deployment name

### Resource Information
- `AI_PROJECT_NAME` - Name of the AI project
- `AI_SERVICES_NAME` - Name of the AI services account
- `AZURE_SEARCH_SERVICE_NAME` - Name of the search service
- `COSMOS_DB_NAME` - Name of the Cosmos DB account
- `STORAGE_ACCOUNT_NAME` - Name of the storage account
- `RESOURCE_GROUP_NAME` - Name of the resource group

## Scripts

### set-env.sh (Bash)
- Retrieves values from `azd env get-values`
- Writes a `.env` file to the project root
- Exports variables for the current shell session
- Works on Linux, macOS, and WSL

### set-env.ps1 (PowerShell)
- Same functionality as the bash script
- Works on Windows PowerShell and PowerShell Core
- Creates UTF-8 encoded `.env` file

## Using Environment Variables

### In Python
```python
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Access variables
project_endpoint = os.getenv('PROJECT_ENDPOINT')
model_name = os.getenv('MODEL_DEPLOYMENT_NAME')
```

### In Node.js
```javascript
require('dotenv').config();

// Access variables
const projectEndpoint = process.env.PROJECT_ENDPOINT;
const modelName = process.env.MODEL_DEPLOYMENT_NAME;
```

### In .NET
```csharp
// Add to your project
// dotnet add package Microsoft.Extensions.Configuration
// dotnet add package Microsoft.Extensions.Configuration.EnvironmentVariables

var configuration = new ConfigurationBuilder()
    .AddEnvironmentVariables()
    .Build();

var projectEndpoint = configuration["PROJECT_ENDPOINT"];
var modelName = configuration["MODEL_DEPLOYMENT_NAME"];
```

## Azure Developer CLI Integration

The project is configured to automatically run the environment setup scripts after deployment via the `azure.yaml` postdeploy hooks.

## Manual Setup

If you need to manually set up the environment variables:

1. Copy `.env.template` to `.env`
2. Run `azd env get-values` to see available outputs
3. Fill in the values in the `.env` file

## Troubleshooting

- If variables are empty, ensure the deployment completed successfully
- Check that you're running the scripts from the project root directory
- Verify that `azd` is installed and you're logged in to Azure
- Make sure you have the correct permissions to read deployment outputs
