# from process import tryon
# from erase_bg import erase_bg
# from fastapi import FastAPI, HTTPException, Form, File, UploadFile
# from imgurpython import ImgurClient
# import os

# app = FastAPI()

# client_id = os.getenv('IMGUR_CLIENT_ID')
# client_secret = os.getenv('IMGUR_CLIENT_SECRET')

# UPLOAD_DIRECTORY = "./uploads"

# @app.post("/tryon")
# async def virtual_tryon(
#     file: UploadFile = File(...),
#     cloth_path: str = Form(...),
# ):
#     try:
#         img_path = os.path.join(UPLOAD_DIRECTORY, file.filename)
#         with open(img_path, "wb") as buffer:
#             buffer.write(img_file.file.read())
#         img_path = img_path.strip()
#         cloth_path = UPLOAD_DIRECTORY+'/'+str(cloth_path)+'.jpg'
#         print(img_path)
#         cloth_path = cloth_path.strip()
#         print(cloth_path)
#         print("erasing img bg")
#         erase_bg(img_path)
#         print("erasing cloth bg")
#         erase_bg(cloth_path)
#         print("generating tryon.....")
#         img_cloth_path = tryon(img_path, cloth_path)
#         client = ImgurClient(client_id, client_secret)
#         uploaded_image = client.upload_from_path(img_cloth_path, anon=True)

#         return {"generated_image": uploaded_image['link']}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))


# if __name__ == "__main__":
#     import uvicorn

#     uvicorn.run(app, host="0.0.0.0", port=8888)

from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from process import tryon
from erase_bg import erase_bg
from imgurpython import ImgurClient
import os
from dotenv import load_dotenv


load_dotenv()

app = Flask(__name__)

client_id = os.getenv('IMGUR_CLIENT_ID')
client_secret = os.getenv('IMGUR_CLIENT_SECRET')
ngrok = os.getenv('NGROK')

UPLOAD_DIRECTORY = "/home/shivankar/sviton2/StableVITON/uploads/"
BASE_DIRECTORY = "/home/shivankar/sviton2/StableVITON/"
if not os.path.exists(UPLOAD_DIRECTORY):
    os.makedirs(UPLOAD_DIRECTORY)

@app.route("/tryon", methods=["POST"])
def virtual_tryon():
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No file part"}), 400
        file = request.files['file']
        cloth_path = request.form.get('cloth_path')
        
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400
        
        if file and cloth_path:
            img_path = os.path.join(UPLOAD_DIRECTORY, secure_filename(file.filename))
            file.save(img_path)
            img_path = img_path.strip()
            cloth_path = os.path.join(UPLOAD_DIRECTORY, secure_filename(cloth_path) + '.jpg')
            print(img_path)
            cloth_path = cloth_path.strip()
            print(cloth_path)
            print("erasing img bg")
            erase_bg(img_path)
            print("erasing cloth bg")
            erase_bg(cloth_path)
            print("generating tryon.....")
            try_on_path = tryon(img_path, cloth_path)
            print(try_on_path)
            link = f"{ngrok}/sviton2/StableVITON/{try_on_path}"
            # print(client_id)
            # # print(client_secret)
            # # client = ImgurClient(client_id, client_secret)
            # # print(client)
            # # uploaded_image = client.upload_from_path(BASE_DIRECTORY+img_cloth_path, anon=True)
            # print(uploaded_image)
            
            return jsonify({"generated_image": link})
        else:
            return jsonify({"error": "Invalid input"}), 400
        # return jsonify({"generated_image": "https://i.imgur.com/bkGNzA9.jpeg"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888)
    # img_cloth_path = tryon('/home/shivankar/sviton2/StableVITON/uploads/IMG-20240615-WA0008.jpg', '/home/shivankar/sviton2/StableVITON/uploads/666ae34eecc9bfb6045f1b33.jpg')
    # print(img_cloth_path)
