import json
import boto3
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
DYNAMODB_TABLE = "ProcessedData"

def decimal_default(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

def calculate_mean(values):
    total = sum(values)
    count = len(values)
    return total / count if count > 0 else 0

def calculate_median(values):
    sorted_values = sorted(values)
    n = len(sorted_values)
    if n == 0:
        return 0
    if n % 2 == 1:
        return sorted_values[n // 2]
    else:
        return (sorted_values[n // 2 - 1] + sorted_values[n // 2]) / 2

def calculate_standard_deviation(values, mean):
    n = len(values)
    if n <= 1:
        return 0
    variance = sum((x - mean) ** 2 for x in values) / (n - 1)
    return variance ** 0.5

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
    
    # Manually calculate statistics
    mean = calculate_mean(values)
    median = calculate_median(values)
    standard_deviation = calculate_standard_deviation(values, mean)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'device_id': device_id,
            'mean': mean,
            'median': median,
            'standard_deviation': standard_deviation
        }, default=decimal_default)
    }
