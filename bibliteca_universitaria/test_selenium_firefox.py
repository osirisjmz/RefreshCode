from selenium import webdriver
from selenium.webdriver.firefox.service import Service
from webdriver_manager.firefox import GeckoDriverManager
import time

# Inicializar Firefox automáticamente
driver = webdriver.Firefox(service=Service(GeckoDriverManager().install()))

# Abre la página local del servidor Flask
driver.get("http://127.0.0.1:5000")

# Espera unos segundos para visualizar el sitio
time.sleep(5)

# Cierra el navegador
driver.quit()
