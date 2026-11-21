#!/bin/bash

echo "Environment is set to: $ENVIRONMENT"

# Step 1: Prompt the user for the stage ID
read -p "Enter the stage name (e.g., dev, staging, prod): " STAGE_ID

# Check if the stage ID is empty
if [ -z "$STAGE_ID" ]; then
  echo "Error: Stage name cannot be empty!"
  exit 1
fi

# Load the environment variables from the .env file
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  source $ENV_FILE
else
  echo "Error: Environment file $ENV_FILE not found!"
  exit 1
fi

# Check if the required variables are loaded
if [ -z "$PROJECT_NAME" ] || [ -z "$REGION" ]; then
  echo "Error: PROJECT_ID or REGION not set in .env!"
  exit 1
fi

echo "Loaded environment variables: STAGE_ID=$STAGE_ID, PROJECT_ID=$PROJECT_NAME, REGION=$REGION"

# Step 2: Build the project
echo "Building the project with yarn..."
yarn build

cd dist

zip -r function_source.zip . -x "node_modules/*" -x "terraform/*" -x "zip/*" -x".git/*" -x".github/*" -x".vscode/*" -x"src/*"
mkdir zip

# Step 3: Move the zip file to the zip/ folder
mv function_source.zip zip/
echo "Moved the zip file to the zip/ folder"

# Step 4: Change directory based on the environment
if [ "$ENVIRONMENT" == "dev" ]; then
  cd terraform/env/dev || exit 1
elif [ "$ENVIRONMENT" == "stage" ]; then
  cd terraform/env/stage || exit 1
elif [ "$ENVIRONMENT" == "prod" ]; then
  cd terraform/env/prod || exit 1
else
  echo "Unknown stage: $ENVIRONMENT. Exiting."
  exit 1
fi

# Step 5: Initialize and apply Terraform configuration

echo "Initializing Terraform..."
terraform init

echo "Creating Terraform plan..."
terraform plan -out=tfplan

echo "Applying Terraform plan..."
terraform apply tfplan

echo "Cleaning up Terraform plan file..."
rm -f tfplan

echo "Deployment completed successfully."

