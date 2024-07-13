import google.auth
from google.oauth2 import service_account
import google.auth.transport.requests

# Servis hesabı anahtar dosyasının yolunu belirtin
SERVICE_ACCOUNT_FILE = '/Users/suhakarakaya/Desktop/nott-e39a2-400d7165198f.json'

# Gerekli yetki kapsamını belirtin
SCOPES = ['https://www.googleapis.com/auth/cloud-platform']

# Servis hesabı bilgilerini yükleyin
credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES)

# Yetki isteği hazırlayın
auth_req = google.auth.transport.requests.Request()

# Erişim tokenı al
credentials.refresh(auth_req)
access_token = credentials.token

print("Access Token:", access_token)
