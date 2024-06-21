from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_community.document_loaders import WebBaseLoader
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.llms import LlamaCpp
from langchain_community.embeddings import LlamaCppEmbeddings
from langchain.callbacks.manager import CallbackManager
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

class ChatRAG:
    def __init__(self):
        self.vectorstore = Chroma(persist_directory='vector_db', embedding_function=LlamaCppEmbeddings(model_path="llama-2-7b-chat.Q4_0.gguf",n_gpu_layers=-1,verbose=False))
        self.retriever = self.vectorstore.as_retriever()
        self.n_gpu_layers = -1 
        self.n_batch = 512  
        # self.callback_manager = CallbackManager([StreamingStdOutCallbackHandler()])
        self.llm = LlamaCpp(
            model_path="llama-2-7b-chat.Q4_0.gguf",
            n_gpu_layers=self.n_gpu_layers,
            n_batch=self.n_batch,
            n_ctx=2048,
            f16_kv=True,  
            # callback_manager=self.callback_manager,
            verbose=False,
        )
        ### Contextualize question ###
        contextualize_q_system_prompt = """Given a chat history and the latest user question \
        which might reference context in the chat history, formulate a standalone question \
        which can be understood without the chat history. Do NOT answer the question, \
        just reformulate it if needed and otherwise return it as is."""
        self.contextualize_q_prompt = ChatPromptTemplate.from_messages(
            [
                ("system", contextualize_q_system_prompt),
                MessagesPlaceholder("chat_history"),
                ("human", "{input}"),
            ]
        )
        self.history_aware_retriever = create_history_aware_retriever(
            self.llm, self.retriever, self.contextualize_q_prompt
        )
        ### Answer question ###
        qa_system_prompt = """You are a shopping assistant for user question-answering tasks. \
        Use the following pieces of retrieved context to answer the question. \
        If you don't know the answer, just say that you don't know. \
        Use three sentences maximum and keep the answer concise. Make sure you sound humanlike so that people want to buy based on your advise. Don't generate the possible human response just your answer directly\

        {context}"""
        self.qa_prompt = ChatPromptTemplate.from_messages(
            [
                ("system", qa_system_prompt),
                MessagesPlaceholder("chat_history"),
                ("human", "{input}"),
            ]
        )
        self.question_answer_chain = create_stuff_documents_chain(self.llm, self.qa_prompt)

        self.rag_chain = create_retrieval_chain(self.history_aware_retriever, self.question_answer_chain)
        self.store = {}
        self.conversational_rag_chain = RunnableWithMessageHistory(
            self.rag_chain,
            self.get_session_history,
            input_messages_key="input",
            history_messages_key="chat_history",
            output_messages_key="answer",
            
        )
    def get_session_history(self,session_id: str) -> BaseChatMessageHistory:
        if session_id not in self.store:
            self.store[session_id] = ChatMessageHistory()
        return self.store[session_id]
    def chat(self,question:str):
        result = self.conversational_rag_chain.invoke(
        {"input": question},
        config={
            "configurable": {"session_id": "abc123"}
        },)
        return {
            'answer': result['answer'],
            'document_ids': result['context']
        }

if __name__ == '__main__':
    crag = ChatRAG()
    dic1 = crag.chat('Suggest Me some gaming laptop from Asus')
    print(dic1['answer'])
    print(" "*50)
    dic2 = crag.chat('Can you show me one from Dell?')
    print(dic2['answer'])
    