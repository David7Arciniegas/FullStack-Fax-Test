provider "aws" {
  region = "us-west-2"
}

# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
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

# Create an IAM policy for the Lambda function to access the S3 bucket
resource "aws_iam_policy" "s3_policy" {
  name = "s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.my_bucket.arn}",
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the S3 policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
  role = "${aws_iam_role.lambda_execution_role.name}"
}

# Create a Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my_lambda_function"
  role = "${aws_iam_role.lambda_execution_role.arn}"
  filename = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
  runtime = "python3.7"
  handler = "lambda_function.handler"
  memory_size = 128
  timeout = 5
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "my_api_gateway" {
  name = "my_api_gateway"
  description = "My API Gateway"
}

# Create a resource for the Lambda function in the API Gateway
resource "aws_api_gateway_resource" "my_api_gateway_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.my_api_gateway.id}"
  parent_id = "${aws_api_gateway_rest_api.my_api_gateway.root_resource_id}"
  path_part = "my_lambda_function"
}

# Create a POST method for the Lambda function in the API Gateway
resource "aws_api_gateway_method" "my_api_gateway_method" {
  rest_api_id = "${aws_api_gateway_rest_api.my_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.my_api_gateway_resource.id}"
  http_method = "POST"
  authorization = "NONE"
}

# Create an integration between the API Gateway and the Lambda function
resource "aws_api_gateway_integration" "my_api_gateway_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.my_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.my_api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.my_api_gateway_method.http_method}"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.my_lambda_function.arn}/invocations"
}

