from msrest.authentication import ApiKeyCredentials
from azure.cognitiveservices.vision.customvision.prediction import CustomVisionPredictionClient


 # Authenticate a client for the prediction API
credentials = ApiKeyCredentials(in_headers={"Prediction-key": "c30b0204989244c1ad1f5c3c271bffef"})
prediction_client = CustomVisionPredictionClient(endpoint="https://eastus2.api.cognitive.microsoft.com/",
                                                 credentials=credentials)

# Get classification predictions for an image
image_data = open("<PATH_TO_IMAGE_FILE>"), "rb").read()
results = prediction_client.classify_image("/subscriptions/a187552d-ac9a-48ae-b5a9-1137187c42b4/resourceGroups/visionosirisAi/providers/Microsoft.CognitiveServices/accounts/fruit",
                                           "fruit",
                                           image_data)

# Process predictions
for prediction in results.predictions:
    if prediction.probability > 0.5:
        print(image, ': {} ({:.0%})'.format(prediction.tag_name, prediction.probability))