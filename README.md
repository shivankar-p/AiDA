# RAG-TTS pipeline Setup

This repository contains the code for a Flask backend that serves machine learning models for audio text-to-speech (TTS) using the AudioTTS module. The backend is designed to be used in conjunction with the RAG (Retrieve and Generate) module.

## Installation

Clone the repo and follow the instructions in order

##### Audio TTS Setup

To install the required dependencies, make sure you have Python, Anaconda installed and run the following command:

```shell
pip install -r requirements.txt
```

This will install all the necessary packages specified in the `requirements.txt` file.

##### RAG Setup

Make sure you install the following dependencies using the command:

```shell
pip install langchain langchain-community chromadb
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python==0.2.47 --upgrade
```

The second command makes sure that llama-cpp-python is installed with CUDA support to run using NVIDIA GPUs.

## Usage

To start the Flask backend, run the following command:

```shell
python api.py
```

This will start the server on `http://localhost:8890`.
