package com.wintep.notepad_alarm;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class PowerButtonReceiver extends BroadcastReceiver {
    private static final String CHANNEL = "com.wintep.notepad_alarm.powerButton";
    private MethodChannel methodChannel;

    public PowerButtonReceiver(FlutterEngine flutterEngine) {
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction() != null) {
            if (intent.getAction().equals(Intent.ACTION_SCREEN_OFF)) {
                // Send message to Flutter when the screen is turned off
                methodChannel.invokeMethod("screenTurnedOff", null);
            } else if (intent.getAction().equals(Intent.ACTION_SCREEN_ON)) {
                // Send message to Flutter when the screen is turned on
                methodChannel.invokeMethod("screenTurnedOn", null);
            }
        }
    }

    public void register(Context context) {
        IntentFilter filter = new IntentFilter(Intent.ACTION_SCREEN_OFF);
        context.registerReceiver(this, filter);
    }

    public void unregister(Context context) {
        context.unregisterReceiver(this);
    }
}
