#!/bin/bash
# Script to set environment variables from azd outputs and write to .env file

echo "Getting infrastructure outputs..."

# Get outputs from azd
PROJECT_ENDPOINT=$(azd env get-values | grep PROJECT_ENDPOINT | cut -d'=' -f2 | tr -d '"')
MODEL_DEPLOYMENT_NAME=$(azd env get-values | grep MODEL_DEPLOYMENT_NAME | cut -d'=' -f2 | tr -d '"')
AZURE_SEARCH_ENDPOINT=$(azd env get-values | grep AZURE_SEARCH_ENDPOINT | cut -d'=' -f2 | tr -d '"')
AZURE_OPENAI_ENDPOINT=$(azd env get-values | grep AZURE_OPENAI_ENDPOINT | cut -d'=' -f2 | tr -d '"')

# Get individual model deployment names (if available)
GPT_4O_DEPLOYMENT=$(azd env get-values | grep GPT_4O_DEPLOYMENT | cut -d'=' -f2 | tr -d '"')
GPT_41_DEPLOYMENT=$(azd env get-values | grep GPT_41_DEPLOYMENT | cut -d'=' -f2 | tr -d '"')
TEXT_EMBEDDING_DEPLOYMENT=$(azd env get-values | grep TEXT_EMBEDDING_DEPLOYMENT | cut -d'=' -f2 | tr -d '"')

# Get optional resource names
AI_PROJECT_NAME=$(azd env get-values | grep AI_PROJECT_NAME | cut -d'=' -f2 | tr -d '"')
AI_SERVICES_NAME=$(azd env get-values | grep AI_SERVICES_NAME | cut -d'=' -f2 | tr -d '"')
AZURE_SEARCH_SERVICE_NAME=$(azd env get-values | grep AZURE_SEARCH_SERVICE_NAME | cut -d'=' -f2 | tr -d '"')
COSMOS_DB_NAME=$(azd env get-values | grep COSMOS_DB_NAME | cut -d'=' -f2 | tr -d '"')
STORAGE_ACCOUNT_NAME=$(azd env get-values | grep STORAGE_ACCOUNT_NAME | cut -d'=' -f2 | tr -d '"')
RESOURCE_GROUP_NAME=$(azd env get-values | grep RESOURCE_GROUP_NAME | cut -d'=' -f2 | tr -d '"')

# Set default values for model deployments if not found in outputs
GPT_4O_DEPLOYMENT=${GPT_4O_DEPLOYMENT:-"gpt-4o"}
GPT_41_DEPLOYMENT=${GPT_41_DEPLOYMENT:-"gpt-4.1"}
TEXT_EMBEDDING_DEPLOYMENT=${TEXT_EMBEDDING_DEPLOYMENT:-"text-embedding-3-large"}

echo "Writing environment variables to .env file..."

# Create .env file
cat > .env << EOF
# Environment Variables for AI Foundry Project
# Generated automatically from azd deployment outputs on $(date)

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
EOF

# Also export for current session
export PROJECT_ENDPOINT="$PROJECT_ENDPOINT"
export MODEL_DEPLOYMENT_NAME="$MODEL_DEPLOYMENT_NAME"
export GPT_4O_DEPLOYMENT="$GPT_4O_DEPLOYMENT"
export GPT_41_DEPLOYMENT="$GPT_41_DEPLOYMENT"
export TEXT_EMBEDDING_DEPLOYMENT="$TEXT_EMBEDDING_DEPLOYMENT"
export AZURE_SEARCH_ENDPOINT="$AZURE_SEARCH_ENDPOINT"
export AZURE_OPENAI_ENDPOINT="$AZURE_OPENAI_ENDPOINT"

# Export optional variables if they exist
[ -n "$AI_PROJECT_NAME" ] && export AI_PROJECT_NAME="$AI_PROJECT_NAME"
[ -n "$AI_SERVICES_NAME" ] && export AI_SERVICES_NAME="$AI_SERVICES_NAME"
[ -n "$AZURE_SEARCH_SERVICE_NAME" ] && export AZURE_SEARCH_SERVICE_NAME="$AZURE_SEARCH_SERVICE_NAME"
[ -n "$COSMOS_DB_NAME" ] && export COSMOS_DB_NAME="$COSMOS_DB_NAME"
[ -n "$STORAGE_ACCOUNT_NAME" ] && export STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_NAME"
[ -n "$RESOURCE_GROUP_NAME" ] && export RESOURCE_GROUP_NAME="$RESOURCE_GROUP_NAME"

echo "✅ Environment variables written to .env file"
echo "✅ Environment variables exported for current session"
echo ""
echo "Key environment variables:"
echo "PROJECT_ENDPOINT=$PROJECT_ENDPOINT"
echo "MODEL_DEPLOYMENT_NAME=$MODEL_DEPLOYMENT_NAME"
echo "GPT_4O_DEPLOYMENT=$GPT_4O_DEPLOYMENT"
echo "GPT_41_DEPLOYMENT=$GPT_41_DEPLOYMENT"
echo "TEXT_EMBEDDING_DEPLOYMENT=$TEXT_EMBEDDING_DEPLOYMENT"
echo "AZURE_SEARCH_ENDPOINT=$AZURE_SEARCH_ENDPOINT"
echo "AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT"

echo ""
echo "To use these variables in your application:"
echo "1. Load the .env file in your application"
echo "2. Or source this script: source ./infra/scripts/set-env.sh"
