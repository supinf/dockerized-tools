const fs = require('fs');
const request = require('request');
const puppeteer = require('puppeteer');

(async() => {

    const browser = await puppeteer.launch({
      executablePath: 'google-chrome-unstable',
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });
    const page = await browser.newPage();
    const file = 'sample-' + new Date().getTime() + ".png";
    await page.goto(process.env.TARGET || 'https://example.com');
    await page.screenshot({path: file, fullPage: true});

    browser.close();

    // https://api.slack.com/custom-integrations/legacy-tokens
    if (process.env.SLACK_LEGACY_TOKEN != null) {
      const res = await post({
        url: 'https://slack.com/api/files.upload',
        formData: {
          file: fs.createReadStream('./' + file),
          filename: file,
          channels: process.env.CHANNEL || 'general',
          token: process.env.SLACK_LEGACY_TOKEN
        }
      });
      console.dir(res);
    }
})();

function post(options) {
  return new Promise(function (resolve, reject) {
    request.post(options, function (err, res, body) {
      if (!err && res.statusCode == 200) {
        resolve(body);
      } else {
        reject(err);
      }
    });
  });
}
