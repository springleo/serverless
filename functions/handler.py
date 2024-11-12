import json
import uuid
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('FeedbackTable')

def handler(event, context):
    print(event)
    data = json.loads(event['body'])
    feedback = data.get('feedback')
    
    if not feedback:
        return {"statusCode": 400, "body": "Invalid input"}

    table.put_item(Item={"id": str(uuid.uuid4()), "feedback": feedback})
    return {"statusCode": 200, "body": json.dumps({"message": "Feedback saved"})}
