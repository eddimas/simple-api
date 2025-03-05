import json
import boto3
import statistics
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
DYNAMODB_TABLE = "ProcessedData"

def decimal_default(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

def lambda_handler(event, context):
    # Extract device_id from query parameters
    query_parameters = event.get("queryStringParameters", {})
    if not query_parameters:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'device_id is required as a query parameter'})
        }
    
    device_id = query_parameters.get("device_id")
    if not device_id:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'device_id is required as a query parameter'})
        }
    
    # Query DynamoDB for the device data
    table = dynamodb.Table(DYNAMODB_TABLE)
    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('device_id').eq(device_id)
    )
    
    items = response.get('Items', [])
    values = [float(item['value']) for item in items if 'value' in item]
    
    if not values:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'No data found for the given device_id'})
        }
    
    # Calculate statistics
    mean = statistics.mean(values)
    median = statistics.median(values)
    stdev = statistics.stdev(values) if len(values) > 1 else 0
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'device_id': device_id,
            'mean': mean,
            'median': median,
            'standard_deviation': stdev
        }, default=decimal_default)
    }
