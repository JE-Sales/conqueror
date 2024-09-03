package com.example.conqueror.inference;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.util.Log;

import org.opencv.android.OpenCVLoader;
import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;
import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.flex.FlexDelegate;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;

public class InferenceEngine {

    private Interpreter tflite;
    private int inputHeight;
    private int inputWidth;
    private FlexDelegate flexDelegate;

    static {
        if (!OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "Static initialization failed!");
        } else {
            Log.d("OpenCV", "Static initialization successful!");
        }
    }

    public InferenceEngine(Context context) {
        // Load the TFLite model with Flex delegate
        try {
            flexDelegate = new FlexDelegate();
            tflite = new Interpreter(loadModelFile(context), new Interpreter.Options().addDelegate(flexDelegate));
            int[] inputShape = tflite.getInputTensor(0).shape(); // {1, height, width, 3}
            inputHeight = inputShape[1];
            inputWidth = inputShape[2];
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private MappedByteBuffer loadModelFile(Context context) throws IOException {
        AssetFileDescriptor fileDescriptor = context.getAssets().openFd("model.tflite");
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getDeclaredLength();
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }

    public String runInference(Bitmap bitmap) {
        // Convert Bitmap to Mat
        Mat imgMat = new Mat();
        Utils.bitmapToMat(bitmap, imgMat);

        // Convert color from RGBA to RGB
        Imgproc.cvtColor(imgMat, imgMat, Imgproc.COLOR_RGBA2RGB);

        // Resize the image to match the input size
        Imgproc.resize(imgMat, imgMat, new Size(inputWidth, inputHeight));

        // Convert image to float32
        imgMat.convertTo(imgMat, CvType.CV_32FC3);

        // Add batch dimension and convert Mat to ByteBuffer
        ByteBuffer inputBuffer = convertMatToByteBuffer(imgMat);

        float[][][] output = new float[1][64][75]; // Adjust based on your model's output shape
        tflite.run(inputBuffer, output);

        // Decode the output
        String charList = "z9k5ijq.E0TPr,LcfDyumotYKO-QJ;d:Bn?b8lNWHI4s6'g7U!1A3)pweV#MRF\"GZvax&h(S2C";
        return ctcDecoder(output[0], charList);
    }

    private ByteBuffer convertMatToByteBuffer(Mat imgMat) {
        // Allocate ByteBuffer with batch dimension (1)
        ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4 * 1 * inputWidth * inputHeight * 3); // 1 for batch size, 3 for RGB channels
        byteBuffer.order(ByteOrder.nativeOrder());

        // Create float array to hold image data
        float[] floatValues = new float[inputWidth * inputHeight * 3];
        imgMat.get(0, 0, floatValues);

        // Put float values into ByteBuffer
        for (float value : floatValues) {
            byteBuffer.putFloat(value);
        }

        return byteBuffer;
    }

    private String ctcDecoder(float[][] predictions, String chars) {
        StringBuilder decodedText = new StringBuilder();
        int prevIndex = -1;

        for (int i = 0; i < predictions.length; i++) {
            float[] timestepPredictions = predictions[i];

            int maxIndex = -1;
            float maxValue = -Float.MAX_VALUE;
            for (int j = 0; j < timestepPredictions.length; j++) {
                if (timestepPredictions[j] > maxValue) {
                    maxValue = timestepPredictions[j];
                    maxIndex = j;
                }
            }

            // Add the character only if it's not the same as the previous one
            if (maxIndex != prevIndex && maxIndex < chars.length()) {
                decodedText.append(chars.charAt(maxIndex));
            }
            prevIndex = maxIndex;
        }

        return decodedText.toString();
    }

    public void close() {
        if (tflite != null) {
            tflite.close();
            tflite = null;
        }
        if (flexDelegate != null) {
            flexDelegate.close();
            flexDelegate = null;
        }
    }
}
