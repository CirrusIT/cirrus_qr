import Flutter
import UIKit

public class SwiftCirrusQrPlugin: NSObject, FlutterPlugin {
    
    var controller: FlutterViewController!
    var imagesResult: FlutterResult?
    var messenger: FlutterBinaryMessenger;
    let genericError = "500"
    
    init(cont: FlutterViewController, messenger: FlutterBinaryMessenger) {
        self.controller = cont;
        self.messenger = messenger;
        super.init();
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cirrus_qr", binaryMessenger: registrar.messenger())
        let app =  UIApplication.shared
        let controller : FlutterViewController = app.delegate!.window!!.rootViewController as! FlutterViewController;
        let instance = SwiftCirrusQrPlugin.init(cont: controller, messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method){
        case "pickImage":
            let sourceType: UIImagePickerControllerSourceType = "camera" == (call.arguments as? String) ? .camera : .photoLibrary
            let imagePicker = self.buildImagePicker(sourceType: sourceType, completion: result)
            self.controller.present(imagePicker, animated: true, completion: nil)
        default:
            break
        }
    }
    
    
    func buildImagePicker(sourceType: UIImagePickerControllerSourceType, completion: @escaping (_ result: Any?) -> Void) -> UIViewController {
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alert = UIAlertController(title: "Error", message: "Camera not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                completion(FlutterError(code: "camera_unavailable", message: "camera not available", details: nil))
            })
            print("que retorna aqui>> \(alert)")
            return alert
        } else {
            return ImagePickerController(sourceType: sourceType) { image in
                self.controller.dismiss(animated: true, completion: nil)
                if let image = image {
                    completion(self.saveToFile(image: image))
                    print(" Image: \(image)")
                } else {
                    completion(FlutterError(code: "user_cancelled", message: "User did cancel", details: nil))
                }
            }
        }
    }
    
    
    private func saveToFile(image: UIImage) -> Any {
        
        guard let data = UIImageJPEGRepresentation(image, 1.0) else {
            return FlutterError(code: "image_encoding_error", message: "Could not read image", details: nil)
        }
        
        //codigo para decodificar;
        
        let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let ciImage:CIImage=CIImage(image: image)!
        var qrCodeLink=""
        let features=detector.features(in: ciImage)
        for feature in features as! [CIQRCodeFeature]{
            qrCodeLink += feature.messageString!
        }
        let tempDir = NSTemporaryDirectory()
        let imageName = "image_picker_\(ProcessInfo().globallyUniqueString).jpg"
        let filePath = tempDir.appending(imageName)
        if FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil) {
            return qrCodeLink
            // return filePath
        } else {
            return FlutterError(code: "image_save_failed", message: "Could not save image to disk", details: nil)
        }
    }
}
class ImagePickerController: UIImagePickerController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var handler: ((_ image: UIImage?) -> Void)?
    
    convenience init(sourceType: UIImagePickerControllerSourceType, handler: @escaping (_ image: UIImage?) -> Void) {
        self.init()
        self.sourceType = sourceType
        self.delegate = self
        self.handler = handler
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        handler?(info[UIImagePickerControllerOriginalImage] as? UIImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        handler?(nil)
    }
}
