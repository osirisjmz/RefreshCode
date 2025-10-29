import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.firefox.launch(headless=False)
        page = await browser.new_page()
        await page.goto("https://www.cms.gov/medicare/physician-fee-schedule/search?Y=0&T=4&HT=0&CT=3&H1=99214&M=5")
        print(await page.title())
        #await browser.close()

asyncio.run(main())
