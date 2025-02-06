import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Create a FastAPI app instance
app = FastAPI()

# Add CORS middleware to the app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,  # Allow cookies to be included in CORS requests
    allow_methods=["*"],  # Allow all HTTP methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)

# Define a Pydantic model for the request body
class Query(BaseModel):
    prompt: str  # The prompt string for the API

# Define an endpoint for POST requests to "/generate"
@app.post("/generate")
def generate_response(query: Query):
    # Send a POST request to the API with the provided prompt
    response = requests.post(
        "http://localhost:11434/api/generate",  # ✅ API URL
        json={"model": "deepseek-r1:1.5b", "prompt": query.prompt},
        stream=True  # ✅ Enable streaming
    )
    
    # Print the response text for debugging purposes
    print("Response Text:", response.text)  # ✅ Debug Response

    try:
        # Return the response as JSON
        return response.json()  # ✅ Convert response to JSON
    except requests.exceptions.JSONDecodeError:
        # Handle invalid JSON response
        return {"error": "Invalid JSON response", "raw_response": response.text}

# Run the FastAPI app using Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
