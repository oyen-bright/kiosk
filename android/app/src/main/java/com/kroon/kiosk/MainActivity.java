package com.kroon.kiosk;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import sunmi.paylib.SunmiPayKernel;



// import io.flutter.embedding.android.FlutterActivity


public class MainActivity extends FlutterFragmentActivity  {
    private static final String CHANNEL = "kroon.Kisok/sunmipay";

//    public BasicOptV2 basicOptV2;           // 获取基础操作模块
//    public ReadCardOptV2 readCardOptV2;     // 获取读卡模块
//    public PinPadOptV2 pinPadOptV2;         // 获取PinPad操作模块
//    public SecurityOptV2 securityOptV2;     // 获取安全操作模块
//    public EMVOptV2 emvOptV2;               // 获取EMV操作模块
//    public TaxOptV2 taxOptV2;               // 获取税控操作模块
//    public ETCOptV2 etcOptV2;               // 获取ETC操作模块
//    public PrinterOptV2 printerOptV2;       // 获取打印操作模块
//    public SunmiPrinterService sunmiPrinterService;
//    public IScanInterface scanInterface;
 private boolean connectPaySDK;//是否已连接PaySDK

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // This method is invoked on the main thread.
                            // TODO
                            if (call.method.equals("getSunmiPaySdk")) {
                                String batteryLevel = "Love";
                                bindPaySDKService();

                                if (batteryLevel != "") {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    public void bindPaySDKService() {
        final SunmiPayKernel payKernel = SunmiPayKernel.getInstance();

        payKernel.initPaySDK(this, new SunmiPayKernel.ConnectCallback() {
            @Override
            public void onConnectPaySDK() {
                // LogUtil.e(Constant.TAG, "onConnectPaySDK...");
                // emvOptV2 = payKernel.mEMVOptV2;
                // basicOptV2 = payKernel.mBasicOptV2;
                // pinPadOptV2 = payKernel.mPinPadOptV2;
                // readCardOptV2 = payKernel.mReadCardOptV2;
                // securityOptV2 = payKernel.mSecurityOptV2;
                // taxOptV2 = payKernel.mTaxOptV2;
                // etcOptV2 = payKernel.mETCOptV2;
                // printerOptV2 = payKernel.mPrinterOptV2;
                connectPaySDK = true;
            }

            @Override
            public void onDisconnectPaySDK() {
                // LogUtil.e(Constant.TAG, "onDisconnectPaySDK...");
                connectPaySDK = false;
                // emvOptV2 = null;
                // basicOptV2 = null;
                // pinPadOptV2 = null;
                // readCardOptV2 = null;
                // securityOptV2 = null;
                // taxOptV2 = null;
                // etcOptV2 = null;
                // printerOptV2 = null;
//                Utility.showToast(R.string.connect_fail);
            }
        });



    }

}