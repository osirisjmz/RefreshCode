import msal
import requests
import json
import pandas as pd
import os
import datetime
from urllib.parse import urlparse, parse_qs
from http.server import HTTPServer, BaseHTTPRequestHandler

# === FUNCIONES DE LOG ===
def log(message, log_path="logs/email_reader_graph.log"):
    os.makedirs("logs", exist_ok=True)
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_path, "a", encoding="utf-8") as log_file:
        log_file.write(f"[{timestamp}] {message}\n")
    print(message)

# === LEER CONFIGURACIÓN ===
def read_config(path="config.json"):
    try:
        log("🧩 Leyendo archivo de configuración...")
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        log("✅ Configuración cargada correctamente.")
        return data
    except FileNotFoundError:
        log(f"❌ ERROR: No se encontró el archivo {path}")
        raise
    except json.JSONDecodeError as e:
        log(f"❌ ERROR: Archivo JSON mal formado → {e}")
        raise

# === SERVIDOR LOCAL TEMPORAL PARA OAUTH ===
class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)
        self.server.auth_code = query.get("code", [None])[0]
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"You can close this window now.")
    def log_message(self, format, *args):  # suprimir logs en consola
        return

def get_auth_code(auth):
    app = msal.PublicClientApplication(
        client_id=auth["client_id"],
        authority=f"https://login.microsoftonline.com/{auth['tenant_id']}"
    )
    flow = app.initiate_auth_code_flow(auth["scope"], redirect_uri=auth["redirect_uri"])
    log("🔑 URL de autorización generada, abre en navegador para autenticar:")
    log(flow["auth_uri"])
    server = HTTPServer(("localhost", 8000), OAuthHandler)
    server.handle_request()
    return flow, server.auth_code

# === OBTENER TOKEN DE ACCESO ===
def get_token(auth):
    try:
        log("🚀 Iniciando flujo de autenticación con Azure...")
        app = msal.ConfidentialClientApplication(
            client_id=auth["client_id"],
            client_credential=auth["client_secret"],
            authority="https://login.microsoftonline.com/consumers"
        )

        result = app.acquire_token_silent(auth["scope"], account=None)
        if result:
            log("🔐 Token recuperado desde caché.")
        else:
            log("🌐 Solicitando nuevo token de acceso vía navegador...")
            flow, code = get_auth_code(auth)
            result = app.acquire_token_by_authorization_code(
                code, scopes=auth["scope"], redirect_uri=auth["redirect_uri"]
            )

        if "access_token" not in result:
            log(f"❌ Error al obtener token: {result.get('error_description')}")
            raise Exception(result.get("error_description"))

        log("✅ Token de acceso obtenido correctamente.")
        return result["access_token"]
    except Exception as e:
        log(f"❌ ERROR durante autenticación: {e}")
        raise

# === LECTURA DE CORREOS CON GRAPH API ===
def fetch_emails(token, limit=10, output_folder="datasets"):
    try:
        log("📨 Conectando a Microsoft Graph API para obtener correos...")
        headers = {"Authorization": f"Bearer {token}"}
        url = f"https://graph.microsoft.com/v1.0/me/messages?$top={limit}"

        response = requests.get(url, headers=headers)
        log(f"🔁 Respuesta HTTP: {response.status_code}")

        if response.status_code != 200:
            log(f"❌ Error en Graph API: {response.text}")
            raise Exception(response.text)

        data = response.json().get("value", [])
        log(f"✅ Se obtuvieron {len(data)} correos.")

        emails = [
            {
                "from": m.get("from", {}).get("emailAddress", {}).get("address", ""),
                "subject": m.get("subject", ""),
                "received": m.get("receivedDateTime", "")
            }
            for m in data
        ]

        df = pd.DataFrame(emails)
        os.makedirs(output_folder, exist_ok=True)
        output_file = os.path.join(output_folder, "emails_graph.csv")
        df.to_csv(output_file, index=False, encoding="utf-8")
        log(f"📁 Dataset guardado en: {output_file}")
    except Exception as e:
        log(f"❌ ERROR durante la lectura de correos: {e}")
        raise

# === MAIN ===
if __name__ == "__main__":
    try:
        log("🔵 ===== INICIO DE PROCESO EMAIL READER GRAPH =====")
        config = read_config()

        auth = config.get("azure_auth", {})
        limit = config.get("email_account", {}).get("fetch_limit", 10)
        output_folder = config.get("paths", {}).get("dataset_folder", "datasets")

        token = get_token(auth)
        fetch_emails(token, limit=limit, output_folder=output_folder)

        log("✅ Proceso completado exitosamente.")
        log("🔵 ===== FIN DE PROCESO =====\n")
    except Exception as e:
        log(f"💥 ERROR FATAL: {e}")
