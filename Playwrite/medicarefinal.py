from playwright.sync_api import sync_playwright
import pandas as pd
import time

#  ExcelPath
excel_path = r"C:\Users\Ocyriz\Documents\InnovaSolutions\dispatcher\Data\Input\cptcode.xlsx"   # ⬅ cambia esta ruta

# Pandas Library to read Excel
df = pd.read_excel(excel_path)

# Ignore header and read has list the CPT_Code
codes = df["CPT_Code"].dropna().tolist()

# Edge Browser Path
edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

for code in codes:
    print(f" Starting process for code Number: {code}")

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=False,
            executable_path=edge_path  # Browser executable path
        )

        context = browser.new_context(
            viewport={"width": 1920, "height": 1080} # emulate windows maximize
        )
        page = context.new_page()

        # Open the site
        page.goto("https://www.cms.gov/medicare/physician-fee-schedule/search?Y=0&T=4&HT=0&CT=3&H1=99214&M=5")

        # Wait appears and hit "Accept"
        page.wait_for_selector("#acceptPFSLicense")
        page.click("#acceptPFSLicense")
        print(" Botón 'Accept' clickeado con éxito")

        # waith for the field and enter the code
        page.wait_for_selector("#h1")
        page.fill("#h1", str(code))
        print(f" Código '{code}' Typed correctly")

        # Hit in  "Search fees"
        page.wait_for_selector("button:has-text('Search fees')")
        page.click("button:has-text('Search fees')")
        print(" Button 'Search fees' Cliecked has successfully")

        # wait for "Download CSV" button and click it
        page.wait_for_selector("button:has-text('Download CSV')", timeout=60000)
        page.click("button:has-text('Download CSV')")
        print(f" Download the code {code} initialized successfully")

        # wait for a while to observe or complete the download
        time.sleep(10)

        browser.close()
        print(f"🟢 Process ended for the {code}\n")

print(" All the codes from the excel file was processed has success.")
