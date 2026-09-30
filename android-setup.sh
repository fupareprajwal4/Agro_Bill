#!/usr/bin/env bash
# Run once after `npm install`, from the project folder (billing-app-local).
set -e
npm run build
npx cap add android
# Make the WebView respect status/navigation bars (needed for Android 15 edge-to-edge)
MA=$(find android/app/src/main/java -name MainActivity.java)
PKG_LINE=$(head -1 "$MA")
cat > "$MA" <<JAVA
$PKG_LINE

import android.os.Bundle;
import android.view.View;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        View root = findViewById(android.R.id.content);
        ViewCompat.setOnApplyWindowInsetsListener(root, (v, windowInsets) -> {
            Insets bars = windowInsets.getInsets(
                WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout());
            Insets ime = windowInsets.getInsets(WindowInsetsCompat.Type.ime());
            v.setPadding(bars.left, bars.top, bars.right, Math.max(bars.bottom, ime.bottom));
            return WindowInsetsCompat.CONSUMED;
        });
    }
}
JAVA
# Legacy storage permission only for Android 9 and below (Android 14/15 need none)
MF=android/app/src/main/AndroidManifest.xml
grep -q WRITE_EXTERNAL_STORAGE "$MF" || sed -i 's#</manifest>#    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />\n</manifest>#' "$MF"
npx cap sync android
echo "Android project ready in ./android"
