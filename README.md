# Explore Terraform, LocalStack, AWS api gateway, AWS lambda hello javascript function

Use lambda proxy integration to integrate an api method with a lambda function. The lambda function is a javascript function that simply returns the string "Hello from Lambda!"

Deploy with

* AWS CLI
* Terraform

## General steps

1. `$ localstack start`
1. Create lambda function
1. Create REST API
1. Get the id of the root resource
1. Create a resource using the root as a parent
1. Add method to resource
1. Create integration
1. Create deployment
1. `$ localstack stop`

## Code

The javscript code for the lambda function is in `lambda.js`.

zip the file into `function.zip`.

```bash
$ zip function.zip lambda.js
...
$
```

## AWS CLI

###

```bash
$ localstack start
```

### Create the lambda function

```bash
$ aws --profile localstack lambda create-function \
  --function-name apigw-lambda \
  --runtime nodejs16.x \
  --handler lambda.apiHandler \
  --memory-size 128 \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::111111111111:role/apigw
```

### Create REST API

```bash
$ aws --profile localstack apigateway create-rest-api \
--name 'API Gateway Lambda integration'

{
    "id": "fxb6vjawg2",
    ...
}
```

You'll need that "id" in the next and later steps.

Copy and paste the value of `"id"` in the following command

```bash
$ rest_api_id=fxb6vjawg2
```

### Get the id of the root resource

```bash
$ aws --profile localstack apigateway get-resources \
--rest-api-id $rest_api_id

{
    "items": [
        {
            "id": "edqon7lp3u",
            "path": "/"
        }
    ]
}
```

You'll need that root resource id in the next and later steps.

Copy and paste the value of `"id"` into this command

```bash
$ root_resource_id=edqon7lp3u
```

### Create a resource using the root resource as its parent

```bash
$ aws --profile localstack apigateway create-resource \
  --rest-api-id $rest_api_id \
  --parent-id $root_resource_id \
  --path-part "{somethingId}"

{
    "id": "a9baesz9x3",
    "parentId": "edqon7lp3u",
    "pathPart": "{somethingId}",
    "path": "/{somethingId}"
}
```

You'll need the "id" of the created resource to add a method to it and integrate it with the lambda function.

Copy and paste into

```bash
$ resource_id=a9baesz9x3
```

### Add method to resource

```bash
$ aws --profile localstack apigateway put-method \
  --rest-api-id $rest_api_id \
  --resource-id $resource_id \
  --http-method GET \
  --request-parameters "method.request.path.somethingId=true" \
  --authorization-type "NONE"
```

### Create integration

Integrate the resource with the lambda function.

```bash
$ aws --profile localstack apigateway put-integration \
  --rest-api-id $rest_api_id \
  --resource-id $resource_id \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:apigw-lambda/invocations \
  --passthrough-behavior WHEN_NO_MATCH
```

### Create deployment

```bash
$ aws --profile localstack apigateway create-deployment \
  --rest-api-id $rest_api_id \
  --stage-name dev
```

### Verify your API

By calling it:

```bash
$ curl -X GET http://${rest_api_id}.execute-api.localhost.localstack.cloud:4566/dev/test

{"message":"Hello from Lambda"}
```

## Terraform
.
.
.
## References

* [API Gateway on LocalStack Guide](https://docs.localstack.cloud/user-guide/aws/apigateway/)
