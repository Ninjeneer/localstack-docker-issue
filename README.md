# LocalStack issue with Lambdas and Docker

You will find here the minimal setup with which I can reproduce my issue

Please note I did not include any localstack pro key, I guess you have everything needed on your side to run the pro container

I let the tfvars in this repo, but they won't be useful - as I replaced the lambda code by a dummy one and still can reproduce

## Reproduction steps
### Step 1 : docker network setup
To be honest I don't if it has an impact, but let's try to stick as much as possible as my local env
```bash
docker network create zenpass
```

### Step 2 : Terraform setup
```bash
cd terraform/localstack
terraform plan
terraform apply

# at some point it will crash, given it's going to try to create a Lambda function based on an unexisting image, it's ok, we just need the ECR to be created at this point
```

### Step 3 : build Lambda image and push to ECR 
This script is useful to me to build many lambdas - I understand you may not want to run an unknown bash script, please feel free to build manually the image instead of using this script
```bash
cd ../..
./build_lambdas.sh
```

### Step 4 : finish Terraform setup
Now that the image is pushed to ECR, we can re-run Terraform apply to create the lambda
```bash
cd terraform/localstack
terraform plan
terraform apply
```

## Machine specs
- Macbook Pro M3
- 36 Go Ram
- Apple Chip
- MacOS Sequoia 15.5
- Docker 4.38.0