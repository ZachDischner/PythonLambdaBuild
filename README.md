## What
This is a demonstrative project that takes your local python environment and bundles it up into an AWS Lambda compatible zipfile using Docker, even works with typically troublesome compiled libs like `numpy` and `pandas`. 

It uses `pipenv` to mange your local environment, so you must have it installed. You can use `conda`, `pyenv`, or just manually manage `requirements.txt`.

In this simple project, a lambda function just imports a few tricky libraries and reads a dataframe from a 

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
