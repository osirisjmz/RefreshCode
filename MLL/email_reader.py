import msal
import requests
import json
import pandas as pd
import os
from urllib.parse import urlparse, parse_qs
from http.server import HTTPServer, BaseHTTPRequestHandler

# === Leer configuración ===
def read_config(path="config.json"):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

config = read_config()
auth = config["azure_auth"]
scope = auth["scope"]

# === Servidor local temporal para capturar el token ===
class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)
        self.server.auth_code = query.get("code", [None])[0]
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"You can close this window now.")
    def log_message(self, format, *args):  # silenciar logs
        return

def get_auth_code():
    app = msal.PublicClientApplication(
        client_id=auth["client_id"],
        authority=f"https://login.microsoftonline.com/{auth['tenant_id']}"
    )
    flow = app.initiate_auth_code_flow(scope, redirect_uri=auth["redirect_uri"])
    print("🔑 Abre esta URL en tu navegador y autoriza el acceso:")
    print(flow["auth_uri"])
    server = HTTPServer(("localhost", 8000), OAuthHandler)
    server.handle_request()
    return flow, server.auth_code

def get_token():
    app = msal.ConfidentialClientApplication(
        client_id=auth["client_id"],
        client_credential=auth["client_secret"],
        authority=f"https://login.microsoftonline.com/{auth['tenant_id']}"
    )
    result = app.acquire_token_silent(scope, account=None)
    if not result:
        flow, code = get_auth_code()
        result = app.acquire_token_by_authorization_code(code, scopes=scope, redirect_uri=auth["redirect_uri"])
    return result["access_token"]

# === Llamada a Microsoft Graph ===
token = get_token()
headers = {"Authorization": f"Bearer {token}"}
url = "https://graph.microsoft.com/v1.0/me/messages?$top=10"

response = requests.get(url, headers=headers)
if response.status_code != 200:
    raise Exception(f"Graph API error: {response.status_code} - {response.text}")

data = response.json().get("value", [])
emails = [{"from": m.get("from", {}).get("emailAddress", {}).get("address", ""),
           "subject": m.get("subject", ""),
           "received": m.get("receivedDateTime", "")} for m in data]

df = pd.DataFrame(emails)
os.makedirs("datasets", exist_ok=True)
df.to_csv("datasets/emails_graph.csv", index=False, encoding="utf-8")
print(f"✅ {len(df)} correos guardados en datasets/emails_graph.csv")
