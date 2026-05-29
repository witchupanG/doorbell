// Service worker — cache เปลือกแอปให้เปิดได้ไว/ออฟไลน์ (ส่วนการยิงไป ntfy ผ่านเน็ตเสมอ)
const CACHE = "doorbell-v1";
const ASSETS = ["./", "./index.html", "./manifest.json", "./icon-192.png", "./icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const url = new URL(e.request.url);
  // อย่าแตะการสื่อสารกับ ntfy — ให้วิ่งผ่านเน็ตตรงๆ เสมอ
  if (e.request.method !== "GET" || url.hostname.includes("ntfy")) return;
  e.respondWith(caches.match(e.request).then(r => r || fetch(e.request)));
});
