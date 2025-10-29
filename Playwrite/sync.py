from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    page = browser.new_page()
    page.goto("https://www.cms.gov/medicare/physician-fee-schedule/search?Y=0&T=4&HT=0&CT=3&H1=99214&M=5")
    print(page.title())
    browser.close()
