const puppeteer = require('puppeteer');

(async() => {

    const browser = await puppeteer.launch({
      executablePath: 'google-chrome-unstable',
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });
    const page = await browser.newPage();
    await page.goto(process.env.TARGET || 'https://example.com');
    await page.screenshot({path: 'sample-' + new Date().getTime() + ".png", fullPage: true});

    browser.close();

})();
