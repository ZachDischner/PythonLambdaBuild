import pandas as pd
import numpy as np
import boto3
import io
def handler(event, context):
    print("Handling event")
    x = np.random.rand(100)
    print(f"How about a numpy array?: {x}")

    print("Lets try a csv from s3 into pandas")
    s3 = boto3.client('s3')
    obj = s3.get_object(Bucket='public-bucket-for-demo', Key='data.csv')
    df = pd.read_csv(io.BytesIO(obj['Body'].read()))
    print(f"CSV: {df.to_json()}")
    