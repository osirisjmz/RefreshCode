import os

def drive_read(file_name, mime_type="text/plain"):
    """
    FUTURO: Leer archivo directamente de Google Drive por ID.
    """
    if not os.getenv("USE_DRIVE"):
        raise RuntimeError("Drive API deshabilitada.")
    # Aquí irá el bloque de conexión con service = build('drive', 'v3', credentials=creds)
    pass

def drive_upload(local_path, remote_folder_id):
    """
    FUTURO: Subir archivo a Drive (logs, reportes, etc.)
    """
    pass
