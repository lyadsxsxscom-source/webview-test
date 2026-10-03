#!/bin/bash
# يشتغل بعد "npx cap add android": يثبّت مفتاح التوقيع حتى تتحدّث النسخ فوق بعضها بدون مشاكل
set -e

# 2) نسخ الـ keystore الثابت (بدل واحد عشوائي يتغيّر كل بناء)
cp debug.keystore android/app/debug.keystore
echo "✓ debug.keystore نُسخ"

# 5) ربط signingConfig الديبج بالـ keystore الثابت (بدل الافتراضي العشوائي بكل بيئة)
if ! grep -q "signingConfigs" android/app/build.gradle; then
  sed -i "/android {/a\\    signingConfigs {\\n        debug {\\n            storeFile file('debug.keystore')\\n            storePassword 'android'\\n            keyAlias 'androiddebugkey'\\n            keyPassword 'android'\\n        }\\n    }" android/app/build.gradle
  sed -i "/buildTypes {/,/debug {/{/debug {/a\\            signingConfig signingConfigs.debug
  }" android/app/build.gradle
  echo "✓ signingConfig مربوط بالـ keystore الثابت"
fi

echo "تجهيز التوقيع خلص."
