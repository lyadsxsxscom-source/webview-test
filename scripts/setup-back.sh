#!/bin/bash
# يشتغل بعد "npx cap add android": يتحكم بزر الرجوع بالأندرويد
#  - إذا الموقع فيه صفحة قبل: يرجع صفحة
#  - غير هيك: أول ضغطة بتعرض رسالة، والضغطة التانية خلال ثانيتين بتطلّع من التطبيق
set -e
F=$(find android/app/src/main/java -name MainActivity.java | head -1)
if [ -z "$F" ]; then echo "✗ MainActivity.java غير موجود"; exit 1; fi
PKG=$(grep -m1 '^package ' "$F" | sed 's/^package //; s/;.*$//; s/\r//')
cat > "$F" <<EOF
package $PKG;

import android.os.Bundle;
import android.webkit.WebView;
import android.widget.Toast;
import androidx.activity.OnBackPressedCallback;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    private long lastBack = 0;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                WebView wv = getBridge() != null ? getBridge().getWebView() : null;
                if (wv != null && wv.canGoBack()) {
                    wv.goBack();
                    return;
                }
                long now = System.currentTimeMillis();
                if (now - lastBack < 2000) {
                    finish();
                } else {
                    lastBack = now;
                    Toast.makeText(MainActivity.this, "\u0627\u0636\u063a\u0637 \u0645\u0631\u0629 \u062a\u0627\u0646\u064a\u0629 \u0644\u0644\u062e\u0631\u0648\u062c", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }
}
EOF
echo "✓ MainActivity: زر الرجوع + تأكيد الخروج ($PKG)"
