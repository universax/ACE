# ASR, TTSの停止
echo "ASRとTTSを停止しています..."
cd ./reazonspeech_asr
make stop

# 2. TTSの停止
cd ../stylebertvits2_tts
make stop

# 3. Audio2Faceの停止
echo "Audio2Faceを停止しています..."
cd ../audio_2_face_microservice/1.2/quick-start
docker compose down
cd ../../..

# 4. ACEの停止
echo "ACEを停止しています..."
cd ./ace_agent/4.1
docker compose -f deploy/docker/docker-compose.yml down