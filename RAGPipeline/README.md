### Setting Up Rag 

For Nvidia GPU machines use the command


```CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python==0.2.47 --upgrade ```

All RAG related APIs are present in chat_rag.py. 

For vectordb creation use create_vector_db.py which takes in the flag 'input_csv' for creating the vector db. 