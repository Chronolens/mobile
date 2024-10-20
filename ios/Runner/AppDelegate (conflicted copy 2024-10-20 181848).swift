import UIKit
import Flutter
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "com.example.mobile/images"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let imageChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        
        GeneratedPluginRegistrant.register(with: self)

        imageChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard call.method == "getAllImagePathsNative" else {
                result(FlutterMethodNotImplemented)
                return
            }

            self?.getAllImagePathsNative(result: result)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Function to retrieve all image paths, asset IDs, and timestamps
    private func getAllImagePathsNative(result: @escaping FlutterResult) {
        // Request authorization to access the photo library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library access denied", details: nil))
                return
            }

            // Fetch assets from the photo library
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            var imagePaths = [[String]]()

            // Iterate through assets and retrieve metadata
            assets.enumerateObjects { (asset, _, _) in
                let assetId = asset.localIdentifier
                let creationDate = asset.creationDate?.timeIntervalSince1970 ?? 0
                let modificationDate = creationDate == 0 ? (asset.modificationDate?.timeIntervalSince1970 ?? 0) : creationDate

                // Use PHAssetResource to get the file path (in most cases not directly accessible)
                let resource = PHAssetResource.assetResources(for: asset).first
                let filePath = resource?.originalFilename ?? ""

                let imageData = [filePath, assetId, String(Int64(modificationDate * 1000))]
                imagePaths.append(imageData)
            }

            // Return the list of image paths, asset IDs, and timestamps
            result(imagePaths)
        }
    }
}

