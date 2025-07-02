#!/bin/bash

BASE_DIR="src/apps/lambdas"
LOCALSTACK_ENDPOINT="000000000000.dkr.ecr.eu-north-1.localhost.localstack.cloud:4566"

# Function to build JavaScript lambdas using esbuild
build_javascript_lambda() {
    local lambda_path="$1"
    local lambda_name=$(basename "$lambda_path")
    # Check if handler.ts exists, otherwise use index.ts
    if [ -f "$lambda_path/handler.ts" ]; then
        local handler_name="handler"
    else
        local handler_name="index" 
    fi
    local handler_path="$lambda_path/$handler_name.ts"
    local out_file="$lambda_path/$handler_name.js"
    local sourcemap_file="$lambda_path/$handler_name.js.map"
    local zip_file="$lambda_path/$lambda_name.zip"

    # Check if tsconfig.json exists
    if [ ! -f "$lambda_path/tsconfig.json" ]; then
        echo "⏭️ Skipping $lambda_name - no tsconfig.json found"
        return 0
    fi

    # Check if pnpm-lock.yaml exists
    if [ ! -f "$lambda_path/pnpm-lock.yaml" ]; then
        echo "📦 No pnpm lock file found, installing dependencies..."
        cd "$lambda_path"
        pnpm install
        if [ $? -ne 0 ]; then
            echo "❌ Failed to install dependencies for $lambda_name"
            cd - > /dev/null
            return 1
        fi
        cd - > /dev/null
    fi

    echo "📦 Building JavaScript lambda: $lambda_name..."

    # Clean previous build
    rm -f "$out_file" "$sourcemap_file" "$zip_file"

    # Build using esbuild with sourcemaps
    esbuild "$handler_path" \
      --bundle \
      --platform=node \
      --target=node20 \
      --outfile="$out_file" \
      --sourcemap \
      --external:aws-sdk

    # Check if build failed
    if [ $? -ne 0 ]; then
        echo "❌ Build failed for $lambda_name"
        return 1
    fi

    # Zip the built file and sourcemap
    cd "$lambda_path"
    zip "$lambda_name.zip" "$handler_name.js" "$handler_name.js.map"
    cd - > /dev/null

    echo "✅ Built JavaScript lambda: $zip_file with sourcemaps"
    return 0
}

# Function to build Docker lambdas and push to localstack ECR
build_docker_lambda() {
    local lambda_path="$1"
    local lambda_name=$(basename "$lambda_path")
    local dockerfile_path="$lambda_path/Dockerfile"
    local ecr_repo_name="fluum-$lambda_name-local"
    local ecr_uri="$LOCALSTACK_ENDPOINT/$ecr_repo_name"
    local image_tag="latest"

    # Check if Dockerfile exists
    if [ ! -f "$dockerfile_path" ]; then
        echo "⏭️ Skipping $lambda_name - no Dockerfile found"
        return 0
    fi

    # Check if pnpm-lock.yaml exists
    if [ ! -f "$lambda_path/pnpm-lock.yaml" ]; then
        echo "📦 No pnpm lock file found, installing dependencies..."
        cd "$lambda_path"
        pnpm install
        if [ $? -ne 0 ]; then
            echo "❌ Failed to install dependencies for $lambda_name"
            cd - > /dev/null
            return 1
        fi
        cd - > /dev/null
    fi

    echo "🐳 Building Docker lambda: $lambda_name..."

    # Build Docker image
    cd "$lambda_path"
    docker buildx build --provenance=false --platform linux/arm64 -t "$lambda_name:$image_tag" .

    # Check if build failed
    if [ $? -ne 0 ]; then
        echo "❌ Docker build failed for $lambda_name"
        cd - > /dev/null
        return 1
    fi

    # Tag for localstack ECR
    docker tag "$lambda_name:$image_tag" "$ecr_uri:$image_tag"

    # Push to localstack ECR
    echo "📤 Pushing $lambda_name to localstack ECR..."
    docker push "$ecr_uri:$image_tag"

    # Check if push failed
    if [ $? -ne 0 ]; then
        echo "❌ Failed to push $lambda_name to localstack ECR"
        cd - > /dev/null
        return 1
    fi

    cd - > /dev/null
    echo "✅ Built and pushed Docker lambda: $lambda_name to $ecr_uri:$image_tag"
    return 0
}

echo "🔍 Searching for lambdas in $BASE_DIR"

# Process each lambda directory
for lambda_path in "$BASE_DIR"/*; do
  if [ -d "$lambda_path" ]; then
    lambda_name=$(basename "$lambda_path")
    
    # Build Docker lambda if it has Dockerfile, otherwise build JavaScript lambda
    if [ -f "$lambda_path/Dockerfile" ]; then
        build_docker_lambda "$lambda_path"
        if [ $? -ne 0 ]; then
            echo "❌ Failed to build Docker lambda: $lambda_name"
            exit 1
        fi
    elif [ -f "$lambda_path/tsconfig.json" ]; then
        build_javascript_lambda "$lambda_path"
        if [ $? -ne 0 ]; then
            echo "❌ Failed to build JavaScript lambda: $lambda_name"
            exit 1
        fi
    else
        echo "⚠️ Skipping $lambda_name - no Dockerfile or tsconfig.json found"
    fi
  fi
done

echo "🎉 All lambdas built successfully!"
