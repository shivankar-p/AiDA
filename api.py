from flask import Flask, request, jsonify
from pydub import AudioSegment
import os

from dotenv import load_dotenv


load_dotenv()

app = Flask(__name__)
BASE_FOLDER = 'home/shivankar/rad-nerf'
UPLOAD_FOLDER = BASE_FOLDER+'/api/uploads'
RESULT_FOLDER = 'rad-nerf/api/results'
DATA_FOLDER = BASE_FOLDER+'/data'
PROCESSED_FOLDER = 'processed'
ALLOWED_EXTENSIONS = {'wav', 'mp3', 'ogg', 'flac'}
BASE_URL = os.getenv('NGROK')


if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

if not os.path.exists(PROCESSED_FOLDER):
    os.makedirs(PROCESSED_FOLDER)


@app.route('/getvideo', methods=['GET'])
def upload_file():
    try:
        # if 'file' not in request.files:
        #     return jsonify(error="No file part"), 400
        # file = request.files['file']
        # if file.filename == '':
        #     return jsonify(error="No selected file"), 400
        # if file:
        #     filename = file.filename
        #     file_path = os.path.join('./api/uploads', filename)
        #     print(file_path)
        #     file.save(file_path)

        #     filename = filename.split('.')[0]

            filename = 'audio'

            print("Extracting features")
            os.system(f"python3 nerf/asr.py --wav api/uploads/{filename}.wav --save_feats")
            print("Generating Video")
            os.system(f"python3 test.py --pose data/olivia/transforms_train.json --ckpt trial_olivia_torso/checkpoints/ngp_ep0081.pth --aud api/uploads/{filename}_eo.npy --bg_img bg.png --workspace trial_olivia/ -O --torso")
            print("Adding audio")
            os.system(f"ffmpeg -y -i trial_olivia/results/ngp_ep0081.mp4 -i api/uploads/{filename}.wav -c:v copy -c:a aac api/results/{filename}.mp4")
            print("Moving to asset folder")
            os.system(f"rm trial_olivia/results/ngp_ep0081.mp4")
            print("overlaying video")
            os.system(f"./overlay.sh api/results/v1.mp4 api/results/{filename}.mp4")

            return jsonify({'path': f"{BASE_URL}/rad-nerf/output.mp4"}), 200

    except Exception as e:
        return jsonify(error=f"An error occurred: {str(e)}"), 500

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8889, debug=True)
