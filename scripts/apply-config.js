// يقرأ app.config.json ويولّد capacitor.config.json وصفحة الأوفلاين.
// كل زبون = تعديل ملف app.config.json بس.
const fs = require("fs");
const path = require("path");
const root = path.join(__dirname, "..");
const cfg = JSON.parse(fs.readFileSync(path.join(root, "app.config.json"), "utf8"));

const fail = m => { console.error("✗ خطأ بـ app.config.json: " + m); process.exit(1); };
if (!/^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$/.test(cfg.appId || "")) fail("appId لازم يكون متل com.client.app (أحرف إنكليزية صغيرة وأرقام ونقاط)");
if (!cfg.appName || !cfg.appName.trim()) fail("appName فاضي");
let u;
try { u = new URL(cfg.url); } catch (e) { fail("url مو رابط صحيح"); }
if (u.protocol !== "https:") fail("url لازم يبدأ بـ https://");
if (!/^#[0-9a-fA-F]{6}$/.test(cfg.themeColor || "")) fail("themeColor لازم يكون متل #0F5C6E");

const host = u.hostname.replace(/^www\./, "");
const capacitor = {
  appId: cfg.appId,
  appName: cfg.appName,
  webDir: "www",
  backgroundColor: cfg.themeColor,
  server: {
    url: cfg.url,
    androidScheme: "https",
    cleartext: false,
    errorPath: "offline.html",
    allowNavigation: [host, "*." + host]
  },
  android: { allowMixedContent: false }
};
fs.writeFileSync(path.join(root, "capacitor.config.json"), JSON.stringify(capacitor, null, 2) + "\n");

const tpl = fs.readFileSync(path.join(root, "scripts", "offline.template.html"), "utf8");
const out = tpl.replace(/{{URL}}/g, cfg.url).replace(/{{COLOR}}/g, cfg.themeColor).replace(/{{NAME}}/g, cfg.appName);
fs.writeFileSync(path.join(root, "www", "offline.html"), out);

// صفحة بداية احتياطية (Capacitor بيطلب وجود www/index.html)
fs.writeFileSync(path.join(root, "www", "index.html"),
  `<!DOCTYPE html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${cfg.appName}</title><meta http-equiv="refresh" content="0;url=${cfg.url}"></head><body style="background:${cfg.themeColor}"></body></html>\n`);

console.log("✓ تم توليد capacitor.config.json و www/offline.html للتطبيق: " + cfg.appName + " → " + cfg.url);
