from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    page = browser.new_page()

    # Ir al sitio
    page.goto("https://www.cms.gov/medicare/physician-fee-schedule/search?Y=0&T=4&HT=0&CT=3&H1=99214&M=5")

    # Esperar a que el botón "Accept" aparezca
    page.wait_for_selector("#acceptPFSLicense")

    # Hacer clic en el botón "Accept"
    page.click("#acceptPFSLicense")
    print("✅ Botón 'Accept' clickeado con éxito")

    # Esperar a que aparezca el input con id="h1"
    page.wait_for_selector("#h1")

    # Escribir el código en el campo de texto
    page.fill("#h1", "99215")
    print("✅ Código '99215' ingresado correctamente")

    # Esperar 10 segundos para observar el resultado
    time.sleep(10)

    browser.close()
