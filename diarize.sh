#!/bin/bash

set -e

# Variables (change these!)
S3_BUCKET="diarized-buddy"
S3_AUDIO_PATH="path/to/input_audio_file.mp3"  # adjust extension
LOCAL_AUDIO_FILE="input_audio"
LOCAL_WAV_FILE="input_audio.wav"
OUTPUT_CSS="merged_output.css"
ASSEMBLYAI_API_KEY="${ASSEMBLYAI_API_KEY:-your_assemblyai_api_key}"
AWS_REGION="us-east-2" # change if needed

# 1. Check/install dependencies

command -v ffmpeg >/dev/null 2>&1 || {
  echo "ffmpeg not found, installing..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y ffmpeg
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install ffmpeg
  else
    echo "Unsupported OS, please install ffmpeg manually"
    exit 1
  fi
}

command -v python3.11 >/dev/null 2>&1 || {
  echo "python3.11 not found, installing..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y python3.11 python3.11-venv python3.11-dev
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install python@3.11
  else
    echo "Unsupported OS, please install python3.11 manually"
    exit 1
  fi
}

# Use python3.11 as python command
PYTHON_CMD=python3.11

# Setup virtual env
$PYTHON_CMD -m venv diarize_env
source diarize_env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install python deps
pip install torch torchaudio pyannote.audio assemblyai boto3

# 2. Download audio from S3
echo "Downloading audio from s3://${S3_BUCKET}/${S3_AUDIO_PATH} ..."
aws s3 cp "s3://${S3_BUCKET}/${S3_AUDIO_PATH}" "./${LOCAL_AUDIO_FILE}" --region ${AWS_REGION}

# 3. Convert to WAV
echo "Converting audio to WAV..."
ffmpeg -y -i "${LOCAL_AUDIO_FILE}" "${LOCAL_WAV_FILE}"

# 4. Run transcription + diarization python script

cat > diarize_run.py << EOF
import os
import assemblyai as aai
from pyannote.audio import Pipeline
import boto3

# Setup
ASSEMBLYAI_API_KEY = os.getenv("ASSEMBLYAI_API_KEY")
if not ASSEMBLYAI_API_KEY:
    raise ValueError("AssemblyAI API key not set in environment variable ASSEMBLYAI_API_KEY")

aai.settings.api_key = ASSEMBLYAI_API_KEY

s3_bucket = "${S3_BUCKET}"
s3_output_key = "diarization_results/${OUTPUT_CSS}"
local_wav_file = "${LOCAL_WAV_FILE}"

# Upload WAV to AssemblyAI for transcription
transcriber = aai.Transcriber()
transcript = transcriber.transcribe(local_wav_file)
print("Transcription done.")

# Run diarization with pyannote
pipeline = Pipeline.from_pretrained("pyannote/speaker-diarization@2.1", use_auth_token=None)
diarization = pipeline(local_wav_file)

# Merge transcript and diarization (basic placeholder - create a css file as example)
with open("${OUTPUT_CSS}", "w") as f:
    f.write("# Diarization merged output (fake example)\n")
    for turn, _, speaker in diarization.itertracks(yield_label=True):
        f.write(f"Speaker {speaker}: {turn.start:.2f} - {turn.end:.2f}\n")
    f.write("\nTranscript text:\n")
    f.write(transcript.text)

# Upload merged css to S3
s3 = boto3.client("s3")
s3.upload_file("${OUTPUT_CSS}", s3_bucket, s3_output_key)
print(f"Uploaded merged diarization to s3://{s3_bucket}/{s3_output_key}")
EOF

echo "Running diarization python script..."
$PYTHON_CMD diarize_run.py

echo "Cleaning up..."
deactivate
rm diarize_run.py
rm -rf diarize_env

echo "Done!"
