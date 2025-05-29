import os

def lambda_handler(event, context):
    print("Hola Mundo desde Lambda en Python!")
    return {
        "statusCode": 200,
        "body": "Hola Mundo"
    }