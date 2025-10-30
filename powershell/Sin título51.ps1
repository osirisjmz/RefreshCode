curl -i -X POST \
  -H "Ocp-Apim-Subscription-Key: <TU_KEY>" \
  -H "Content-Type: application/json" \
  --data "{\"urlSource\":\"https://aka.ms/azsdk/formrecognizer/sample.jpg\"}" \
  "https://osirisjmz.cognitiveservices.azure.com/documentintelligence/documentModels/prebuilt-read:analyze?api-version=2024-11-30"
