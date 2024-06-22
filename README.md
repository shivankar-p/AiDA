## Avatar Generation Pipeline

The flask api for our service is based on the paper - RAD-NeRF: Real-time Neural Talking Portrait Synthesis. For installing all required dependencies please follow the instructions mentioned [here](https://github.com/ashawkey/RAD-NeRF/blob/main/readme.md). To understand how RAD-NeRF works we highly suggest you check the paper from the link [here](https://arxiv.org/abs/2211.12368).

## Usage

Once all RAD-NeRF dependancies are installed, we would need to install flask.

```bash
pip install flask
```

To run the api use the command following -

```bash
python api.py
```

The application will open in `http://localhost:8889`
