# Define important variables

variable "API_KEY" {}
variable "API_URL" {}
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "REGION" {}
variable "STAGE" {}
variable "BUCKET" {}

# Set provider
provider "aws" {
  region = "${var.REGION}"
  access_key = "${var.AWS_ACCESS_KEY}" 
  secret_key = "${var.AWS_SECRET_KEY}" 
}

# Create an IAM role for the Lambda function to assume

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create an IAM role for the api gateway execution
resource "aws_iam_role" "api_gateway_execution_role" {  
  name = "api_gateway_execution_role"  
  
  assume_role_policy = jsonencode({  
    Version = "2012-10-17"  
    Statement = [  
      {  
        Action = "sts:AssumeRole"  
        Effect = "Allow"  
        Principal = {  
          Service = "apigateway.amazonaws.com"  
        }  
      }  
    ]  
  })  
}  
# Create an IAM role for the api gateway to invoke a lambda
resource "aws_iam_role_policy" "api_gateway_lambda_invoke" {  
  name = "api_gateway_lambda_invoke"  
  role = aws_iam_role.api_gateway_execution_role.id  
  
  policy = jsonencode({  
    Version = "2012-10-17"  
    Statement = [  
      {  
        Action = [  
          "lambda:InvokeFunction"  
        ]  
        Effect = "Allow"  
        Resource = aws_lambda_function.my_lambda_function.arn  
      }  
    ]  
  })  
}  

# Create a Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "titan_backend"
  role = aws_iam_role.lambda_execution_role.arn
  filename = "../backend/lambda_function.zip"
  source_code_hash = filebase64sha256("../backend/lambda_function.zip")
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
}

# Create Layer for lambda function that allows axios

resource "aws_lambda_layer_version" "my_layer" {  
  layer_name = "axios"  
  s3_bucket  = "${var.BUCKET}"
  s3_key     = "axios_lambda.zip"
  compatible_runtimes = ["nodejs14.x"]  
}  

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "my_api_gateway" {
  name = "my_api_gateway"
  description = "Test Api gateway for Titans"
}

# Create a resource for the Lambda function in the API Gateway
resource "aws_api_gateway_resource" "my_api_gateway_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.my_api_gateway.id}"
  parent_id = "${aws_api_gateway_rest_api.my_api_gateway.root_resource_id}"
  path_part = "titan_backend"
}

# Create a default model for the method response of the API Gateway, such that it doesnt get CORS errors
resource "aws_api_gateway_model" "empty" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  name          = "Empty"
  content_type  = "application/json"
  schema        = ""
}

# Create a POST method for the Lambda function in the API Gateway
resource "aws_api_gateway_method" "my_api_gateway_method" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id = aws_api_gateway_resource.my_api_gateway_resource.id
  http_method = "POST"
  authorization = "NONE"
  response_models  = {
    "application/json" = aws_api_gateway_model.empty.id
  }
}

# Create an integration between the API Gateway and the Lambda function
resource "aws_api_gateway_integration" "my_api_gateway_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.my_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.my_api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.my_api_gateway_method.http_method}"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.my_lambda_function.arn}/invocations"
  credentials = aws_iam_role.api_gateway_execution_role.arn 
}

# Define a stage for the API Gateway
resource "aws_api_gateway_stage" "my_api_gateway_stage" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  deployment_id = aws_api_gateway_deployment.my_api_gateway_deployment.id
  stage_name = "${var.STAGE}"
}

# Create a new deployment for the API Gateway
resource "aws_api_gateway_deployment" "my_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  depends_on = [aws_api_gateway_integration.my_api_gateway_integration]
}

# Return the endpoint URL
output "api_gateway_endpoint_url" {
  value = "https://${aws_api_gateway_rest_api.my_api_gateway.id}.execute-api.${var.REGION}.amazonaws.com/dev/${aws_lambda_function.my_lambda_function.function_name}"
}

# Return lambdafunction both ARN and name for storing in Secrets
output "lambda_function" {
  value = aws_lambda_function.my_lambda_function.function_name
  description = "Name of the Lambda function"
}

output "lambda_arn" {
  value = aws_lambda_function.my_lambda_function.arn
  description = "ARN of the Lambda function"
}

