#!/bin/bash
set -e

echo "=========================================="
echo "Starting CloudOps Platform Cleanup..."
echo "=========================================="

# 1. Stop local Docker compose stack if running
if [ -f "docker/docker-compose.yml" ]; then
    echo "Stopping local Docker containers..."
    docker compose -f docker/docker-compose.yml down -v
fi

# 2. Terraform Destroy (Dev Environment)
echo "Do you want to destroy the AWS dev infrastructure via Terraform? (y/N)"
read -r CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    echo "Destroying Terraform dev environment..."
    cd terraform/environments/dev
    terraform destroy -auto-approve
    echo "Dev infrastructure destroyed successfully."
else
    echo "Skipping Terraform destroy."
fi

echo "=========================================="
echo "Cleanup completed."
echo "=========================================="
