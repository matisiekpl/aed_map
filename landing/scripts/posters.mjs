import {mkdir} from 'node:fs/promises'
import {chromium} from 'playwright'

const baseUrl = process.env.BASE_URL || 'http://localhost:3000'
const locales = ['pl', 'en', 'de', 'es', 'fr', 'it']
const formats = ['a4', 'a5']

const browser = await chromium.launch()
const page = await browser.newPage()

for (const locale of locales) {
  await mkdir(`public/posters/${locale}`, {recursive: true})
  for (const format of formats) {
    const prefix = locale === 'pl' ? '' : `/${locale}`
    await page.goto(`${baseUrl}${prefix}/branding/print/${format}`, {waitUntil: 'networkidle'})
    await page.waitForFunction(() => document.querySelector('h2')?.style.fontSize)
    await page.pdf({path: `public/posters/${locale}/${format}.pdf`, preferCSSPageSize: true, printBackground: true})
    console.log(`public/posters/${locale}/${format}.pdf`)
  }
}

await browser.close()
