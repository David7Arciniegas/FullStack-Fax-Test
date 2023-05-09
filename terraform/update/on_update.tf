# Define important variables

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "REGION" {}
variable "BUCKET" {}
variable "API_KEY" {}
variable "API_URL" {}
variable "STAGE" {}
variable "LAMBDA_NAME" {}
variable "LAMBDA_EXECUTION_ROLE" {}
# Set provider
provider "aws" {
  region = "${var.REGION}"
  access_key = "${var.AWS_ACCESS_KEY}" 
  secret_key = "${var.AWS_SECRET_KEY}" 
}

# Create a Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "${var.LAMBDA_NAME}"
  role = "${var.LAMBDA_EXECUTION_ROLE}"
  filename = "../../backend/lambda_function.zip"
  source_code_hash = filebase64sha256("../../backend/lambda_function.zip")
  runtime = "nodejs14.x"
  handler = "handler.handler"
  memory_size = 128
  timeout = 30
  layers = [  
    aws_lambda_layer_version.my_layer.arn  
  ]
  environment {
    variables = {
      API_KEY = "${var.API_KEY}",
      API_URL = "${var.API_URL}"
    } 
  }
  lifecycle {
    ignore_changes = [arn, last_modified_time]
}
}

# Create Layer for lambda function that allows axios

resource "aws_lambda_layer_version" "my_layer" {  
  layer_name = "axios"  
  s3_bucket  = "${var.BUCKET}"
  s3_key     = "axios_lambda.zip"
  compatible_runtimes = ["nodejs14.x"]  
}  
