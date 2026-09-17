const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

const APK_DIR = path.join(__dirname, '..', 'build', 'app', 'outputs', 'flutter-apk');
const VARIANTS = {
  '/momentum.apk': 'app-arm64-v8a-release.apk',
  '/momentum-universel.apk': 'app-release.apk',
};
const PORT = 8000;

function lanAddress() {
  for (const entries of Object.values(os.networkInterfaces())) {
    for (const entry of entries || []) {
      if (entry.family === 'IPv4' && !entry.internal && entry.address.startsWith('192.168.')) {
        return entry.address;
      }
    }
  }
  return 'localhost';
}

http.createServer((req, res) => {
  const file = VARIANTS[req.url];
  if (!file) {
    const links = Object.keys(VARIANTS)
      .map((url) => `<li><a href="${url}">${url.slice(1)}</a></li>`)
      .join('');
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(`<meta name=viewport content="width=device-width,initial-scale=1">
      <body style="font:16px system-ui;background:#0b0b0e;color:#f2f2f2;padding:32px">
      <h1 style="letter-spacing:-.04em">Momentum</h1><ul style="line-height:2">${links}</ul>`);
    return;
  }

  const apk = path.join(APK_DIR, file);
  if (!fs.existsSync(apk)) {
    res.writeHead(404);
    res.end('APK introuvable — lance `flutter build apk --release` d\'abord.');
    return;
  }

  res.writeHead(200, {
    'Content-Type': 'application/vnd.android.package-archive',
    'Content-Length': fs.statSync(apk).size,
    'Content-Disposition': `attachment; filename="${file}"`,
  });
  fs.createReadStream(apk).pipe(res);
}).listen(PORT, '0.0.0.0', () => {
  console.log(`Depuis le telephone (meme Wi-Fi) : http://${lanAddress()}:${PORT}/`);
});
