# Dockerized [GoogleChrome/puppeteer](https://github.com/GoogleChrome/puppeteer)

[![supinf/puppeteer](http://dockeri.co/image/supinf/puppeteer)](https://hub.docker.com/r/supinf/puppeteer/)

## Supported tags and respective `Dockerfile` links:

・latest ([nodejs/puppeteer/versions/1.11/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/nodejs/puppeteer/versions/1.11/Dockerfile))  
・1.11 ([nodejs/puppeteer/versions/1.11/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/nodejs/puppeteer/versions/1.11/Dockerfile))  

## Usage

### headless

Specify google-chrome-unstable as its executablePath.

```
$ cat << EOF > index.js
const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({
    executablePath: 'google-chrome-unstable',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });
  const page = await browser.newPage();
  await page.goto('https://example.com');
  await page.screenshot({path: 'example.png', fullPage: true});
  browser.close();
})();
EOF
$ docker run --rm -it -v $(pwd):/work supinf/puppeteer node index.js
```

### headless false

Run XQuartz

```
$ brew cask install xquartz
$ local_ip_address=$( ifconfig en0 | grep inet | awk '$1=="inet" {print $2}' ) \
    && echo ${local_ip_address}
$ open -a XQuartz
$ (Open 'Security tab' & click 'Allow connections from network clients')
$ (Restart XQuartz)
$ (Input `xhost <your-local-ip-address>` on the XQuartz terminal)
```

Then,

```
$ cat << EOF > index.js
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    executablePath: 'google-chrome-unstable',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
    headless: false,
    slowMo: 300
  });
  const page = await browser.newPage();
  await page.setViewport({width: 1024, height: 768});
  await page.goto('https://developers.google.com/web/');

  // Type into search box.
  await page.type('#searchbox input', 'Headless Chrome');

  // Wait for suggest overlay to appear and click "show all results".
  const btn = '.devsite-suggest-all-results';
  await page.waitForSelector(btn);
  await page.click(btn);

  // Wait for the results page to load and display the results.
  const results = '.gsc-results .gsc-thumbnail-inside a.gs-title';
  await page.waitForSelector(results);

  // Extract the results from the page.
  const links = await page.evaluate(selector => {
    const anchors = Array.from(document.querySelectorAll(selector));
    return anchors.map(anchor => {
      const title = anchor.textContent.split('|')[0].trim();
      return \`\${title} - \${anchor.href}\`;
    });
  }, results);
  console.log(links.join('\n'));

  await browser.close();
})();
EOF
$ docker run --rm -it -e DISPLAY="${local_ip_address}:0" supinf/puppeteer node -e "$(cat index.js)"
```
