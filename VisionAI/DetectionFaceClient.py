# app.py — Flask demo (Azure Face Detect) with webcam/file/URL
# Run: 1) pip install flask requests
#      2) set env FACE_ENDPOINT and FACE_KEY
#      3) python app.py
# Open http://127.0.0.1:5000

import os
import io
import json
from flask import Flask, request, jsonify, render_template_string
import requests

# ====== Config ======
FACE_ENDPOINT = os.environ.get("FACE_ENDPOINT", "https://osirisfaceid.cognitiveservices.azure.com/")  # e.g., https://<resource>.cognitiveservices.azure.com
FACE_KEY = os.environ.get("FACE_KEY", "37fYQL50kT7o1VYClLlWVBPtaHzsBv2sg3gpOCKXgFmvIGQI7MUiJQQJ99BIACBsN54XJ3w3AAAKACOGgZVC")
FACE_PATH = os.environ.get("FACE_PATH", "/face/v1.0/detect")

ALLOWED_ATTRS_DEFAULT = "qualityForRecognition,blur,exposure,noise,occlusion,headPose,mask"

app = Flask(__name__)

# ====== Templates ======
INDEX_HTML = r"""
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Flask · Azure Face Detect</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, "Helvetica Neue", Arial; margin: 0; background:#0f172a; color:#e5e7eb }
    header { padding: 16px 20px; background:#111827; border-bottom:1px solid #1f2937 }
    .wrap { max-width: 1100px; margin: 0 auto; padding: 20px }
    fieldset { border:1px solid #1f2937; border-radius:12px; padding:14px 16px; margin-bottom:16px; background:#0b1220 }
    legend { padding: 0 8px; font-weight: 700; color:#93c5fd }
    label { display:block; font-size: 12px; color:#9ca3af; margin-bottom:6px }
    input[type="text"], textarea { width:100%; padding:10px 12px; border-radius:10px; border:1px solid #1f2937; background:#0a1020; color:#e5e7eb }
    input[type="file"]{ color:#e5e7eb }
    .row { display:flex; gap:14px; flex-wrap: wrap }
    .col { flex:1 1 260px }
    button { background:#2563eb; border:none; color:#fff; padding:10px 14px; border-radius:10px; cursor:pointer; font-weight:600 }
    button.secondary { background:#374151 }
    .panel { border:1px solid #1f2937; border-radius:12px; padding:12px; background:#0b1220 }
    #outCanvas { max-width:100%; border-radius:12px; background:#020617 }
    .footer { font-size:12px; color:#9ca3af; margin-top:10px }
    .error { color:#fecaca }
    .ok { color:#86efac }
  </style>
</head>
<body>
  <header><div class="wrap"><strong>Azure Face Detect · Flask</strong></div></header>
  <div class="wrap">

    <fieldset>
      <legend>1) Estado del backend</legend>
      <div class="row">
        <div class="col"><div id="status" class="footer"></div></div>
      </div>
    </fieldset>

    <fieldset>
      <legend>2) Imagen (URL o archivo)</legend>
      <div class="row">
        <div class="col">
          <label>Image URL</label>
          <input id="imageUrl" type="text" placeholder="https://raw.githubusercontent.com/Azure-Samples/cognitive-services-sample-data-files/master/ComputerVision/Images/faces.jpg" />
        </div>
        <div class="col">
          <label>Archivo local</label>
          <input id="fileInput" type="file" accept="image/*" />
        </div>
      </div>
      <div class="row">
        <div class="col">
          <label>Parámetros (comma‑separated)</label>
          <input id="attrs" type="text" value="{{ attrs_default }}" />
          <div class="footer">Se envían en <code>returnFaceAttributes</code>. También: <code>returnFaceId=true</code>, <code>returnFaceLandmarks=false</code>, <code>detectionModel=detection_03</code>, <code>recognitionModel=recognition_04</code>.</div>
        </div>
        <div class="col" style="align-self:flex-end">
          <button id="btnDetect">Detectar rostros</button>
          <button id="btnClear" class="secondary">Limpiar</button>
        </div>
      </div>
    </fieldset>

    <fieldset>
      <legend>2.1) Cámara web (opcional)</legend>
      <div class="row">
        <div class="col" style="flex:2 1 420px">
          <label>Vista previa</label>
          <video id="videoEl" autoplay playsinline style="width:100%;max-width:800px;border-radius:12px;border:1px solid #1f2937;background:#020617"></video>
        </div>
        <div class="col" style="align-self:flex-end;display:flex;gap:8px;flex-wrap:wrap">
          <button id="btnStartCam">Iniciar cámara</button>
          <button id="btnCapture" class="secondary">Capturar cuadro</button>
          <button id="btnStopCam" class="secondary">Detener cámara</button>
          <div class="footer">Tras capturar, se usa la imagen para la detección.</div>
        </div>
      </div>
    </fieldset>

    <div class="row">
      <div class="col"><div class="panel"><canvas id="outCanvas"></canvas></div></div>
      <div class="col"><div class="panel"><textarea id="jsonOut" readonly></textarea><div id="msg" class="footer"></div></div></div>
    </div>

    <div class="footer">Backend oculta tu key. Ref: Face Detect REST. Este demo evita atributos deprecados.</div>
  </div>

  <script>
    const $ = (id)=>document.getElementById(id);
    const canvas = $('outCanvas'); const ctx = canvas.getContext('2d');
    const statusEl = $('status'); const msg = $('msg'); const jsonOut = $('jsonOut');

    function setStatus(t, ok=false){ statusEl.textContent=t; statusEl.className = 'footer ' + (ok?'ok':'error'); }
    function setMsg(t, isErr=false){ msg.textContent=t; msg.className = 'footer ' + (isErr?'error':''); }

    async function ping(){
      try{ const r = await fetch('/ping'); const j = await r.json(); setStatus('Backend OK · Face endpoint: '+j.endpoint, true); }
      catch{ setStatus('Backend no disponible', false); }
    }

    function resizeCanvasToImage(img){
      const maxW=800; const scale=Math.min(1, maxW/img.width);
      canvas.width = img.width * scale; canvas.height = img.height * scale;
      ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
      return scale;
    }

    async function drawFacesAndBoxes(faces, src){
      const img = new Image(); img.crossOrigin='anonymous';
      await new Promise((res,rej)=>{ img.onload=res; img.onerror=rej; img.src=src; });
      const scale = resizeCanvasToImage(img);
      if(!Array.isArray(faces)) return;
      ctx.lineWidth=2; ctx.font='12px ui-sans-serif, system-ui';
      faces.forEach((f,i)=>{
        const r=f.faceRectangle||{}; const x=(r.left||0)*scale, y=(r.top||0)*scale, w=(r.width||0)*scale, h=(r.height||0)*scale;
        ctx.strokeStyle='#60a5fa'; ctx.strokeRect(x,y,w,h);
        const a=f.faceAttributes||{}; const label = `#${i+1}${a.qualityForRecognition?` · q:${a.qualityForRecognition}`:''}`;
        const pad=4; const textW = ctx.measureText(label).width + pad*2; const textH = 16;
        ctx.fillStyle='rgba(17,24,39,0.8)'; ctx.fillRect(x, Math.max(0,y-textH), textW, textH);
        ctx.fillStyle='#f3f4f6'; ctx.fillText(label, x+pad, Math.max(12,y-4));
      });
    }

    // Camera
    const videoEl = $('videoEl'); let mediaStream=null; let capturedBlob=null; let lastURL='';
    async function startCam(){ try{ if(mediaStream) return; mediaStream=await navigator.mediaDevices.getUserMedia({video:{width:{ideal:1280},height:{ideal:720}},audio:false}); videoEl.srcObject = mediaStream; setMsg('Cámara lista'); }catch(e){ setMsg('No se pudo iniciar cámara: '+e.message,true);} }
    function stopCam(){ if(mediaStream){ mediaStream.getTracks().forEach(t=>t.stop()); mediaStream=null; } if(videoEl) videoEl.srcObject=null; }
    async function capture(){ if(!mediaStream){ setMsg('Inicia la cámara primero', true); return; } const w=videoEl.videoWidth||640,h=videoEl.videoHeight||480; canvas.width=w; canvas.height=h; ctx.drawImage(videoEl,0,0,w,h); capturedBlob=await new Promise(res=>canvas.toBlob(res,'image/jpeg',0.92)); if(lastURL) URL.revokeObjectURL(lastURL); lastURL = URL.createObjectURL(capturedBlob); setMsg('Cuadro capturado'); }

    async function detect(){
      setMsg(''); jsonOut.value='';
      const imageUrl = $('imageUrl').value.trim();
      const fileInput = $('fileInput');
      const attrs = $('attrs').value.replace(/\s+/g,'').trim();
      const form = new FormData();
      form.append('attributes', attrs);
      if(imageUrl){ form.append('imageUrl', imageUrl); }
      else if(capturedBlob){ form.append('file', capturedBlob, 'frame.jpg'); }
      else if(fileInput.files && fileInput.files[0]){ form.append('file', fileInput.files[0]); }
      else { setMsg('Proporciona una URL, sube un archivo o usa la cámara.', true); return; }

      try{
        setMsg('Detectando…');
        const r = await fetch('/detect', { method:'POST', body: form });
        const t = await r.text(); let data; try{ data = JSON.parse(t); } catch{ data = { raw:t }; }
        if(!r.ok){ jsonOut.value = JSON.stringify(data, null, 2); throw new Error('HTTP '+r.status); }
        jsonOut.value = JSON.stringify(data, null, 2);
        const src = imageUrl || (capturedBlob? lastURL : (fileInput.files[0]? URL.createObjectURL(fileInput.files[0]) : ''));
        if(src) await drawFacesAndBoxes(data, src);
        setMsg('Listo');
      }catch(e){ setMsg('Error: '+e.message, true); }
    }

    $('btnStartCam').addEventListener('click', startCam);
    $('btnStopCam').addEventListener('click', stopCam);
    $('btnCapture').addEventListener('click', capture);
    $('btnDetect').addEventListener('click', detect);
    $('btnClear').addEventListener('click', ()=>{ jsonOut.value=''; setMsg(''); $('imageUrl').value=''; $('fileInput').value=''; capturedBlob=null; stopCam(); ctx.clearRect(0,0,canvas.width,canvas.height); });

    ping();
  </script>
</body>
</html>
"""

# ====== Routes ======
@app.get("/")
def index():
    return render_template_string(INDEX_HTML, attrs_default=ALLOWED_ATTRS_DEFAULT)

@app.get("/ping")
def ping():
    return jsonify({
        "ok": True,
        "endpoint": FACE_ENDPOINT or "<no FACE_ENDPOINT>",
        "path": FACE_PATH
    })

@app.post("/detect")
def detect():
    if not FACE_ENDPOINT or not FACE_KEY:
        return jsonify({"error": "Config missing", "details": "Set FACE_ENDPOINT and FACE_KEY"}), 500

    attrs = (request.form.get("attributes") or "").strip()

    # Build URL with query params
    url = f"{FACE_ENDPOINT.rstrip('/')}{FACE_PATH}"
    params = {
        "returnFaceId": "true",
        "returnFaceLandmarks": "false",
        "detectionModel": "detection_03",
        "recognitionModel": "recognition_04",
    }
    if attrs:
        params["returnFaceAttributes"] = attrs

    headers = {"Ocp-Apim-Subscription-Key": FACE_KEY}

    # Choose body: URL JSON vs binary file
    image_url = request.form.get("imageUrl", "").strip()
    files = None
    data = None
    if image_url:
        headers["Content-Type"] = "application/json"
        data = json.dumps({"url": image_url})
    elif "file" in request.files:
        # Binary upload
        file = request.files["file"]
        headers["Content-Type"] = "application/octet-stream"
        files = None
        data = file.read()
    else:
        return jsonify({"error": "No image provided"}), 400

    try:
        resp = requests.post(url, params=params, headers=headers, data=data, timeout=30)
        # Do not raise for status; return body for debugging
        try:
            payload = resp.json()
        except Exception:
            payload = {"raw": resp.text}
        return (jsonify(payload), resp.status_code)
    except requests.RequestException as e:
        return jsonify({"error": "request_failed", "details": str(e)}), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="127.0.0.1", port=port, debug=True)
