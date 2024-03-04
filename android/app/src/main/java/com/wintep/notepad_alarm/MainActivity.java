package com.wintep.notepad_alarm;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    private PowerButtonReceiver powerButtonReceiver;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        powerButtonReceiver = new PowerButtonReceiver(flutterEngine);
        powerButtonReceiver.register(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        powerButtonReceiver.unregister(this);
    }
}
