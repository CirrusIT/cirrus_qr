package com.example.cirrusqr;

import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

/** CirrusQrPlugin */
public class CirrusQrPlugin implements MethodCallHandler {
  /** Plugin registration. */
  private static final String CHANNEL = "cirrus_qr";
  private final PluginRegistry.Registrar registrar;
  private final ImagePickerDelegate delegate;

  public static void registerWith(PluginRegistry.Registrar registrar) {

    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);

    final ImagePickerDelegate delegate = new ImagePickerDelegate(registrar.activity());


    registrar.addActivityResultListener(delegate);
    registrar.addRequestPermissionsResultListener(delegate);

    final CirrusQrPlugin instance = new CirrusQrPlugin (registrar, delegate);


    channel.setMethodCallHandler(instance);
  }


  @VisibleForTesting
  CirrusQrPlugin(PluginRegistry.Registrar registrar, ImagePickerDelegate delegate) {
    this.registrar = registrar;
    this.delegate = delegate;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (registrar.activity() == null) {
      result.error("no_activity", "image_picker requiere una actividad en primer plano.", null);
      return;
    }
    if (call.method.equals("pickImage")) {
      delegate.chooseImageFromGallery(call, result);
      //delegate.qr();
    } else {
      throw new IllegalArgumentException("Unknown method " + call.method);
    }
  }
}
