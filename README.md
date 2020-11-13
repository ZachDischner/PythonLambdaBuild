## Prerequisites

#### Docker
This uses docker! Install on your machine howerver you see fit

**Mac**
```
brew cask install docker
```

#### Python Env
IDK. Figure out a better project-local python interpreter setup. Just have an env you want to develop against and deploy a variant thereof. 

Modify as you will to use `pip` instead of pipenv. Just need to freeze your requirements manually. 
```
conda create -n py38test python=3.8
pipenv install --user pipenv
```

## DITL
Make sure your env is activated when working on this project
```
conda activate py38test
```

#### Development
Drop into a shell to prototype if you want
```
pipenv run ipython
```

Do your stuff in this dir, `pipenv install` your own requirements, whatever
```
pipenv install numpy pandas
```

#### Artifact
Iterate, test, write code, then build a zip for lambda!

```
./build.sh
```

Inspect `build.sh`, if you want to drop into the built docker container's shell, you can do something like

```
docker build --tag pythonbundler .
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
