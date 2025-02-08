# Import necessary packages
import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Create an instance of the FastAPI
app = FastAPI()

# Add CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,  # Allow credentials
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Define a Pydantic model for the request body
class Query(BaseModel):
    prompt: str

# Define a POST endpoint to generate a response
@app.post("/generate")
def generate_response(query: Query):
    response = requests.post(
        "http://localhost:11434/api/generate",  # API URL
        json={"model": "deepseek-r1:1.5b", "prompt": query.prompt},  # Request body
        stream=True  # Enable streaming
    )
    
    print("Response Text:", response.text)  # Debug Response

    try:
        return response.json()  # Convert response to JSON
    except requests.exceptions.JSONDecodeError:
        return {"error": "Invalid JSON response", "raw_response": response.text}  # Handle JSON decode error

# Run the application if the script is executed directly
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)  # Start the server
