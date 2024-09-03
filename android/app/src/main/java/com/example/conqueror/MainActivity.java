package com.example.conqueror;

import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    private InferenceChannelHandler inferenceChannelHandler;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Initialize the InferenceChannelHandler
        inferenceChannelHandler = new InferenceChannelHandler(this, flutterEngine);
    }

    @Override
    protected void onDestroy() {
        // Clean up the InferenceChannelHandler
        if (inferenceChannelHandler != null) {
            inferenceChannelHandler.close();
        }
        super.onDestroy();
    }
}