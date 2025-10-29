from playwright.sync_api import sync_playwright
import time
import os

with sync_playwright() as p:
    # Ruta del ejecutable de Microsoft Edge
    edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

    browser = p.chromium.launch(
        headless=False,
        executable_path=edge_path  # Le indicamos que use Edge
    )

    context = browser.new_context(
        viewport={"width": 1920, "height": 1080}  # Simula ventana maximizada
    )
    page = context.new_page()

    # Ir al sitio
    page.goto("https://www.cms.gov/medicare/physician-fee-schedule/search")

    # Esperar a que aparezca y hacer clic en "Accept"
    page.wait_for_selector("#acceptPFSLicense")
    page.click("#acceptPFSLicense")
    print("✅ Botón 'Accept' clickeado con éxito")

    # Esperar a que aparezca el campo e ingresar el código
    page.wait_for_selector("#h1")
    page.fill("#h1", "99214")
    print("✅ Código '99214' ingresado correctamente")

    # Esperar y hacer clic en el botón "Search fees"
    page.wait_for_selector("button:has-text('Search fees')")
    page.click("button:has-text('Search fees')")
    print("✅ Botón 'Search fees' clickeado con éxito")

    # Esperar a que aparezca el botón "Download CSV"
    page.wait_for_selector("button:has-text('Download CSV')", timeout=60000)
    page.click("button:has-text('Download CSV')")
    print("✅ Botón 'Download CSV' clickeado con éxito")

    # Esperar 100 segundos para observar o completar la descarga
    time.sleep(100)

    browser.close()
