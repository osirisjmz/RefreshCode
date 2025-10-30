$ENDPOINT = "https://osirisfaceid.cognitiveservices.azure.com/"


curl -sS -X POST "$ENDPOINT/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&detectionModel=detection_03" \
  -H "Ocp-Apim-Subscription-Key: 37fYQL50kT7o1VYClLlWVBPtaHzsBv2sg3gpOCKXgFmvIGQI7MUiJQQJ99BIACBsN54XJ3w3AAAKACOGgZVC" \
  -H "Content-Type: application/json" \
  -d "{\"url\":\"https://raw.githubusercontent.com/Azure-Samples/cognitive-services-sample-data-files/master/ComputerVision/Images/faces.jpg\"}"

