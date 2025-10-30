curl -sS -X POST "$ENDPOINT/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&detectionModel=detection_03" \
  -H "Ocp-Apim-Subscription-Key: KEY" \
  -H "Content-Type: application/json" \
  -d "{\"url\":\"C:/Users/Ocyriz/Pictures/Foto azul.PNG"}"
