from langchain_community.document_loaders.csv_loader import CSVLoader
from langchain_community.embeddings import LlamaCppEmbeddings
from absl import flags
from absl import app
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma

_INPUT_CSV = flags.DEFINE_string('input_csv',None,'Enter Input CSV link',required=True)

def create_vector_db(_argv):
    del _argv
    loader = CSVLoader(file_path=_INPUT_CSV.value)
    data = loader.load()
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
    all_splits = text_splitter.split_documents(data)
    llama_embedding = LlamaCppEmbeddings(model_path="llama-2-7b-chat.Q4_0.gguf",n_gpu_layers=-1,verbose=True)
    Chroma.from_documents(documents=all_splits,persist_directory='vector_db', embedding=llama_embedding)

if __name__ == '__main__':
    app.run(create_vector_db)

