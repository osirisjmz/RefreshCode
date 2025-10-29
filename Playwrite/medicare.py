from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    page = browser.new_page()

    # Ir al sitio
    page.goto("https://www.cms.gov/medicare/physician-fee-schedule/search?Y=0&T=4&HT=0&CT=3&H1=99214&M=5")

    # Esperar a que el botón con el ID "acceptPFSLicense" aparezca en la página
    page.wait_for_selector("#acceptPFSLicense")

    # Hacer clic en el botón "Accept"
    page.click("#acceptPFSLicense")
    print("✅ Botón 'Accept' clickeado con éxito")

    # Esperar 10 segundos para observar el resultado
    time.sleep(10)

    browser.close()
