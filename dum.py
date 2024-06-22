from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Access the environment variables
database_url = os.getenv('IMGUR_CLIENT_ID')
secret_key = os.getenv('IMGUR_CLIENT_ID')

print(f'Database URL: {database_url}')
print(f'Secret Key: {secret_key}')
