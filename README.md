## TL;DR
Zip up a lambda env with docker. Follow these steps to deploy a simple python function, with numpy and pandas included.

```
# Clone and build zip
git clone https://github.com/ZachDischner/PythonLambdaBuild.git && cd PythonLambdaBuild

# Create your local env
pipenv install

# Build the local lambda/env into a zip
./build.sh

# Live demo - create a lambda, role, and invoke
ROLE_ARN=$(aws iam create-role --role-name DEMO_LAMBDA_ROLE --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' | jq -r '.Role.Arn')

aws iam attach-role-policy --role-name DEMO_LAMBDA_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy --role-name DEMO_LAMBDA_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

aws lambda create-function --function-name DEMO_LAMBDA --runtime python3.8 --handler lambda_function.handler --zip-file fileb://`pwd`/lambda.zip --role $ROLE_ARN --region us-east-1

# Invoke it, you should see numpy and pandas borne outputs!
aws lambda invoke --function-name DEMO_LAMBDA out --log-type Tail | jq -r '.LogResult' | base64 --decode

# Now cleanup
aws iam detach-role-policy --role-name DEMO_LAMBDA_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam detach-role-policy --role-name DEMO_LAMBDA_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam delete-role --role-name DEMO_LAMBDA_ROLE
aws lambda delete-function --function-name DEMO_LAMBDA
```

## What
This is a demonstrative project that takes your local python environment and bundles it up into an AWS Lambda compatible zipfile using Docker, even works with typically troublesome compiled libs like `numpy` and `pandas`. It does so with two scripts:
1. `buildLocalEnv.sh` - builds a zip locally from `requirements.txt` and your source code in `src`. Can run this wherever.
2. `build.sh` - essentially runs `buildLocalEnv.sh` from within a docker container, to build a zip file of this project suitable for AWS lambda

It uses `pipenv` to mange your local environment, so you must have it installed. You can always use `conda`, `pyenv`, or just manually manage `requirements.txt`.

In this simple project, a lambda function just imports a few tricky libraries and reads a dataframe from an object in a public bucket in s3.

## Prerequisites

#### Docker
This uses docker! Install on your machine howerver you see fit

**Mac**
```
brew cask install docker
```

#### Python Env
Using pipenv, create an environment based on the pipfile here. If you don't use pipenv, just know that you'll have to mange `requirements.txt` manually.

**Create an environment for this project**
```
pipenv install
```

## DITL
Make sure you are developing against the appropriate environment for this project. Nominally using pipenv.

**Example** I want to use the `requests` module in my lambda handler.

1. Install the module for local testing. This will update the local `Pipenv` file and install it in your local venv.
```
pipenv install requests
```

2. Add `import requests` to the `lambda_function` .py
3. Create your artifact
```
./build.sh
```
4. Upload your zip to a lambda function via the AWS console, CFN, CDK, whatever
5. Go run it, see that `requests` was imported successfully
6. Cleanup
```
pipenv uninstall requests
```

#### Development
Drop into a shell to prototype if you want
```
pipenv run ipython
```

Develop against this dir, `pipenv install` your own requirements. When you're ready to zip up an artifact for Lambda, see below. 

#### Artifact
Iterate, test, write code, then build a zip for lambda!

```
./build.sh
```

Inspect `build.sh`, if you want to drop into the built docker container's shell, you can do something like

```
docker build --nocache --tag pythonbundler .
docker run -it --detach --name test pythonbundler
docker exec -it test bash
# Don't forget to 
docker kill test
docker rm test
```

## IRL
Develop your function, run `build.sh`, and manually upload the zip to the lambda console. 

**Better yet**...

You should have a separate infrastructure project. Reference this core code project's location in that infra project's CDK, `while (developing) zip && deploy` at will

**MyCDKStack.ts**
```
export class MyCDKStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const demoLambda = new lambda.Function(this, "DemoBuildLambda", {
      runtime: lambda.Runtime.PYTHON_3_8,
      handler: "lambda_function.handler",
      // Local reference... could be better
      code: lambda.Code.asset("../lambdaBuild/lambda.zip"),
      timeout: cdk.Duration.minutes(10),
      memorySize: 1280
    });
  }
}
```

Iterate: `cd $LAMBDA_BUILD_DIR && ./build.sh && cd $INFRA_DIR && cdk deploy`. Boom


## TODO
* Maybe pick a pure baseline image
* Figure out a faster build/run setup where you don't need to install deps at every iteration
* Get away from `RUN` commands in docker. Should instead copy the build script in and `EXEC` it I think
