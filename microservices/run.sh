# ASR, TTSの起動
# 1. ASRの起動
echo "ASRを起動しています..."
cd ./reazonspeech_asr
make run-d

# 2. TTSの起動
echo "TTSを起動しています..."
cd ../stylebertvits2_tts
make run-d

# 3. Audio2Faceの起動
echo "Audio2Faceを起動しています..."
cd ../audio_2_face_microservice/1.2/quick-start
docker compose up -d
cd ../../..

# 4. サービスの起動まで待機
echo "ASRとTTSの起動を待っています..."
sleep 30

# 5. ACEの起動
echo "ACEを起動しています..."
cd ./ace_agent/4.1
export NGC_CLI_REGION=asia-northeast1-a
export BOT_PATH=./samples/ace_jp_speech_bot/
source deploy/docker/docker_init.sh
docker compose -f deploy/docker/docker-compose.yml up model-utils
docker compose -f deploy/docker/docker-compose.yml up speech-event-bot -d
echo "すべてのサービスが起動しました"