import json
import boto3
import statistics

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # List objects in the S3 bucket
    bucket_name = 'device-raw-data-bucket'
    prefix = 'processed_data/'
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)



    values = []
    for obj in response.get('Contents', []):
        # Get the object content
        key = obj['Key']
        obj_response = s3.get_object(Bucket=bucket_name, Key=key)
        content = obj_response['Body'].read().decode('utf-8')
        data = json.loads(content)
        values.append(data['value'])

    if not values:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'No data available'})
        }

    # Calculate statistics
    mean = statistics.mean(values)
    median = statistics.median(values)
    stdev = statistics.stdev(values) if len(values) > 1 else 0

    return {
        'statusCode': 200,
        'body': json.dumps({
            'mean': mean,
            'median': median,
            'standard_deviation': stdev
        })
    }