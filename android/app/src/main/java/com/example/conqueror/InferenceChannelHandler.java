package com.example.conqueror;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.annotation.NonNull;

import com.example.conqueror.inference.InferenceEngine;

import java.io.File;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class InferenceChannelHandler implements MethodCallHandler {

    private static final String CHANNEL = "com.example.pensnap/inference";
    private final InferenceEngine inferenceEngine;

    public InferenceChannelHandler(Context context, FlutterEngine flutterEngine) {
        // Initialize the InferenceEngine
        inferenceEngine = new InferenceEngine(context);

        // Set up the method channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("recognizeText")) {
            String imagePath = call.argument("imagePath");
            if (imagePath != null) {
                String recognizedText = recognizeTextFromImage(imagePath);
                result.success(recognizedText);
            } else {
                result.error("INVALID_INPUT", "Image path is null", null);
            }
        } else {
            result.notImplemented();
        }
    }

    private String recognizeTextFromImage(String imagePath) {
        // Load the image from the file path
        Bitmap bitmap = BitmapFactory.decodeFile(new File(imagePath).getAbsolutePath());
        // Run inference using the InferenceEngine
        return inferenceEngine.runInference(bitmap);
    }

    public void close() {
        // Clean up resources in InferenceEngine if necessary
        if (inferenceEngine != null) {
            inferenceEngine.close();
        }
    }
}