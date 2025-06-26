# PowerShell script to set environment variables from azd outputs and write to .env file

Write-Host "Getting infrastructure outputs..."

# Get outputs from azd
$outputs = azd env get-values
$PROJECT_ENDPOINT = ($outputs | Select-String "PROJECT_ENDPOINT" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$MODEL_DEPLOYMENT_NAME = ($outputs | Select-String "MODEL_DEPLOYMENT_NAME" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$AZURE_SEARCH_ENDPOINT = ($outputs | Select-String "AZURE_SEARCH_ENDPOINT" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$AZURE_OPENAI_ENDPOINT = ($outputs | Select-String "AZURE_OPENAI_ENDPOINT" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })

# Get individual model deployment names (if available)
$GPT_4O_DEPLOYMENT = ($outputs | Select-String "GPT_4O_DEPLOYMENT" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$GPT_41_DEPLOYMENT = ($outputs | Select-String "GPT_41_DEPLOYMENT" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$TEXT_EMBEDDING_DEPLOYMENT = ($outputs | Select-String "TEXT_EMBEDDING_DEPLOYMENT" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })

# Get optional resource names
$AI_PROJECT_NAME = ($outputs | Select-String "AI_PROJECT_NAME" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$AI_SERVICES_NAME = ($outputs | Select-String "AI_SERVICES_NAME" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$AZURE_SEARCH_SERVICE_NAME = ($outputs | Select-String "AZURE_SEARCH_SERVICE_NAME" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$COSMOS_DB_NAME = ($outputs | Select-String "COSMOS_DB_NAME" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$STORAGE_ACCOUNT_NAME = ($outputs | Select-String "STORAGE_ACCOUNT_NAME" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })
$RESOURCE_GROUP_NAME = ($outputs | Select-String "RESOURCE_GROUP_NAME" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') })

# Set default values for model deployments if not found in outputs
if (-not $GPT_4O_DEPLOYMENT) { $GPT_4O_DEPLOYMENT = "gpt-4o" }
if (-not $GPT_41_DEPLOYMENT) { $GPT_41_DEPLOYMENT = "gpt-4.1" }
if (-not $TEXT_EMBEDDING_DEPLOYMENT) { $TEXT_EMBEDDING_DEPLOYMENT = "text-embedding-3-large" }

Write-Host "Writing environment variables to .env file..."

# Create .env file content
$envContent = @"
# Environment Variables for AI Foundry Project
# Generated automatically from azd deployment outputs on $(Get-Date)

# AI Foundry Project Endpoint - Main endpoint for your AI project
PROJECT_ENDPOINT=$PROJECT_ENDPOINT

# Primary Model Deployment Name - The name of your primary deployed AI model (gpt-4o)
MODEL_DEPLOYMENT_NAME=$MODEL_DEPLOYMENT_NAME

# Individual Model Deployment Names
GPT_4O_DEPLOYMENT=$GPT_4O_DEPLOYMENT
GPT_41_DEPLOYMENT=$GPT_41_DEPLOYMENT
TEXT_EMBEDDING_DEPLOYMENT=$TEXT_EMBEDDING_DEPLOYMENT

# Azure Search Endpoint - Endpoint for your Azure AI Search service
AZURE_SEARCH_ENDPOINT=$AZURE_SEARCH_ENDPOINT

# Azure OpenAI Endpoint - Endpoint for your Azure OpenAI service
AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT

# Additional useful variables (optional)
AI_PROJECT_NAME=$AI_PROJECT_NAME
AI_SERVICES_NAME=$AI_SERVICES_NAME
AZURE_SEARCH_SERVICE_NAME=$AZURE_SEARCH_SERVICE_NAME
COSMOS_DB_NAME=$COSMOS_DB_NAME
STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME
RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME

# Authentication - You'll need to set these manually or use Azure CLI/SDK authentication
# AZURE_OPENAI_API_KEY=
# AZURE_SEARCH_API_KEY=
"@

# Write to .env file
$envContent | Out-File -FilePath ".env" -Encoding utf8

Write-Host "Setting environment variables for current session..."

# Set environment variables for current session
$env:PROJECT_ENDPOINT = $PROJECT_ENDPOINT
$env:MODEL_DEPLOYMENT_NAME = $MODEL_DEPLOYMENT_NAME
$env:GPT_4O_DEPLOYMENT = $GPT_4O_DEPLOYMENT
$env:GPT_41_DEPLOYMENT = $GPT_41_DEPLOYMENT
$env:TEXT_EMBEDDING_DEPLOYMENT = $TEXT_EMBEDDING_DEPLOYMENT
$env:AZURE_SEARCH_ENDPOINT = $AZURE_SEARCH_ENDPOINT
$env:AZURE_OPENAI_ENDPOINT = $AZURE_OPENAI_ENDPOINT

# Set optional variables if they exist
if ($AI_PROJECT_NAME) { $env:AI_PROJECT_NAME = $AI_PROJECT_NAME }
if ($AI_SERVICES_NAME) { $env:AI_SERVICES_NAME = $AI_SERVICES_NAME }
if ($AZURE_SEARCH_SERVICE_NAME) { $env:AZURE_SEARCH_SERVICE_NAME = $AZURE_SEARCH_SERVICE_NAME }
if ($COSMOS_DB_NAME) { $env:COSMOS_DB_NAME = $COSMOS_DB_NAME }
if ($STORAGE_ACCOUNT_NAME) { $env:STORAGE_ACCOUNT_NAME = $STORAGE_ACCOUNT_NAME }
if ($RESOURCE_GROUP_NAME) { $env:RESOURCE_GROUP_NAME = $RESOURCE_GROUP_NAME }

Write-Host "✅ Environment variables written to .env file" -ForegroundColor Green
Write-Host "✅ Environment variables set for current session" -ForegroundColor Green
Write-Host ""
Write-Host "Key environment variables:"
Write-Host "PROJECT_ENDPOINT=$env:PROJECT_ENDPOINT"
Write-Host "MODEL_DEPLOYMENT_NAME=$env:MODEL_DEPLOYMENT_NAME"
Write-Host "GPT_4O_DEPLOYMENT=$env:GPT_4O_DEPLOYMENT"
Write-Host "GPT_41_DEPLOYMENT=$env:GPT_41_DEPLOYMENT"
Write-Host "TEXT_EMBEDDING_DEPLOYMENT=$env:TEXT_EMBEDDING_DEPLOYMENT"
Write-Host "AZURE_SEARCH_ENDPOINT=$env:AZURE_SEARCH_ENDPOINT"
Write-Host "AZURE_OPENAI_ENDPOINT=$env:AZURE_OPENAI_ENDPOINT"

Write-Host ""
Write-Host "To use these variables in your application:"
Write-Host "1. Load the .env file in your application"
Write-Host "2. Or run this script: .\infra\scripts\set-env.ps1"

