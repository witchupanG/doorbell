// Service worker — กันค้างเวอร์ชันเก่า: หน้า HTML ดึงจากเน็ตก่อนเสมอ (network-first)
// ส่วนไอคอน/ไฟล์ static ใช้ cache-first และการยิงไป ntfy ปล่อยผ่านเน็ตตรงๆ
const CACHE = "doorbell-v5";
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
  const req = e.request;
  const url = new URL(req.url);
  if (req.method !== "GET" || url.hostname.includes("ntfy")) return;   // อย่าแตะ ntfy

  // หน้า HTML / การนำทาง: เอาของใหม่จากเน็ตก่อน แล้วค่อย fallback cache ตอนออฟไลน์
  if (req.mode === "navigate" || req.destination === "document") {
    e.respondWith(
      fetch(req)
        .then(r => { const cp = r.clone(); caches.open(CACHE).then(c => c.put(req, cp)); return r; })
        .catch(() => caches.match(req).then(r => r || caches.match("./index.html")))
    );
    return;
  }

  // ไฟล์ static อื่น: cache-first
  e.respondWith(caches.match(req).then(r => r || fetch(req)));
});
