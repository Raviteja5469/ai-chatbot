# Ollama Chatbot

## Description
This is a chatbot application built using Flutter for the front end and FastAPI for the back end. The chatbot communicates with a local server to generate responses based on user input.

## Features
- User-friendly interface built with Flutter
- Dark theme for the application
- Real-time response generation
- Cross-origin request handling with FastAPI
-JSON request and response handling

## Front End
The front end of the application is built using Flutter. The main components include:
- `OllamaApp`: The main application widget.
- `ChatScreen`: A stateful widget that handles user input and displays responses.
- `askOllama`: A function to send user input to the server and process the response.

## Back End
The back end of the application is built using FastAPI. The main components include:
- `Query`: A Pydantic model for the request body.
- `generate_response`: A POST endpoint to handle requests and generate responses.
- CORS middleware to allow cross-origin requests.

## How to Run
### Front End
1. Ensure you have Flutter installed on your machine. Follow the instructions [here](https://flutter.dev/docs/get-started/install) to install Flutter.
2. Clone this repository.
3. Open the terminal and navigate to the project directory.
4. Run `flutter pub get` to install the dependencies.
5. Run `flutter run` to start the application.

### Back End
1. Ensure you have Python and FastAPI installed on your machine. Follow the instructions [here](https://fastapi.tiangolo.com/) to install FastAPI.
2. Clone this repository.
3. Open the terminal and navigate to the `backend` directory.
4. Run `pip install -r requirements.txt` to install the dependencies.
5. Run `uvicorn main:app --reload` to start the FastAPI server.

## Usage
1. Open the application on your device.
2. Enter a prompt in the text field and press "Send".
3. The application will send the prompt to the server and display the response.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgements
- [Flutter](https://flutter.dev/) - for the front end framework.
- [FastAPI](https://fastapi.tiangolo.com/) - for the back end framework.
- [Pydantic](https://pydantic-docs.helpmanual.io/) - for data validation and parsing.
- [HTTP](https://docs.python-requests.org/en/latest/) - for making HTTP requests... 



