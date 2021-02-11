const express = require('express');
const bodyParser = require("body-parser");
const puppeteer = require('puppeteer');

const app = express();
app.use(bodyParser.json());

const API_KEY = process.env.API_KEY;
const PDFOPTIONS = {
  format: 'A4',
  printBackground: true,
  margin: {
    top: '50px',
    right: '50px',
    bottom: '50px',
    left: '50px'
  }
}


// Setup the browser instance
let BROWSER = null;

(async () => {
  BROWSER = await puppeteer.launch({
    executablePath: '/usr/bin/chromium-browser',
    args: ['--no-sandbox', '--disable-dev-shm-usage']
  });
})();

function auth(req, res, next){
  const key = req.query.api_key;
  const connect_id = req.query.connect_id;
  
  if (API_KEY && API_KEY === key) {
    next();
  } else {
    res.status(401);
    res.send({'message': "Unauthorized"});
  }
}

app.get('/', function (req, res) {
  res.send({'message': 'Hello World!!'});
});

/**
 * Usage:
 * curl 'http://localhost:3000/pdf?api_key=demo&url=https://google.com' -o output.pdf
 */
app.get('/pdf', auth, async (req, res) => {
  const url = req.query.url;
  const download = req.query.download || false;

  if (url) {
    const page = await BROWSER.newPage();
    await page.goto(url, {waitUntil: 'networkidle2'});
    const pdf = await page.pdf(PDFOPTIONS);

    if (download) {
      const filename = new Date().getTime() + '.pdf';
      res.setHeader('Content-disposition', 'attachment; filename=' + filename);
    }
    res.contentType("application/pdf");
    res.send(pdf);

  } else {
    res.status(400);
    res.send({'message': "Parameter 'url' is required"});
  }
});

app.post("/pdf", async (req, res) => {
  let {url, options, cookies, download} = req.body;
  options = options || {};
  const pdf_options = {...PDFOPTIONS, ...options};
  if (url) {

    const page = await BROWSER.newPage();

    if (cookies){
      await page.setCookie(...cookies);

    }

    await page.goto(url, {waitUntil: 'networkidle2'});
    const pdf = await page.pdf(pdf_options);

    if (download) {
      const filename = new Date().getTime() + '.pdf';
      res.setHeader('Content-disposition', 'attachment; filename=' + filename);
    }
    res.contentType("application/pdf");
    res.send(pdf);

  } else {
    res.status(400);
    res.send({'message': "Property 'url' is required"});
  }

})

// tell the server what port to listen on
app.listen(3000, () => {
  console.log('Server started on port 3000');
});
