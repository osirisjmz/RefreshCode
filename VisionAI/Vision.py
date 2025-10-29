import os
from pathlib import Path

image_path = Path(r"C:\Users\Ocyriz\Documents\AI Training\pics\Business-card.jpg")  # ajusta aquí
print("Probando:", image_path)
print("Existe?", image_path.exists())
print("Directorio padre:", image_path.parent)
print("Contenido del directorio padre:")
for x in image_path.parent.glob("*"):
    print(" -", x.name)

from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential

ENDPOINT = "https://osirisjmz.cognitiveservices.azure.com/"
KEY = "2KztFCM0eK3Cr7GXS6DLog3DbERmvubAE9iv7841eQ8XIcIaZkl7JQQJ99BIACBsN54XJ3w3AAAFACOG4kon"

# Crea el cliente
client = ImageAnalysisClient(endpoint=ENDPOINT, credential=AzureKeyCredential(KEY))

# --- Analizar un archivo local ---
image_path = Path("C:/Users/Ocyriz/Documents/Ai Training/pics/Note.jpg")

with open(image_path, "rb") as f:
    image_data = f.read()

result = client.analyze(
    image_data=image_data,
    visual_features=[VisualFeatures.READ]
)

print("=== TEXTO DETECTADO (archivo) ===")
if result.read is not None:
    if getattr(result.read, "content", None):
        print(result.read.content)
    else:
        for b in (result.read.blocks or []):
            for ln in (b.lines or []):
                print(ln.text)

# --- Analizar una imagen pública por URL (opcional) ---
result2 = client.analyze_from_url(
    image_url="https://aka.ms/azsdk/formrecognizer/sample.jpg",
    visual_features=[VisualFeatures.READ]
)
print("\n=== TEXTO DETECTADO (URL) ===")
if result2.read is not None and result2.read.blocks:
    if hasattr(result2.read, "content") and result2.read.content:
        print(result2.read.content)
    else:
        for block in result2.read.blocks:
            for line in block.lines:
                print(line.text)
