import Flutter
import UIKit
import AVFoundation

public class SwiftFlutterVideoCompressPlugin: NSObject, FlutterPlugin {
    private let channelName = "flutter_video_compress"
    private var exporter:AVAssetExportSession? = nil
    private var stopCommand = false
    private var isCompressing = false
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_video_compress", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterVideoCompressPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        switch call.method {
        case "getThumbnail":
            let path = args!["path"] as! String
            let quality = args!["quality"] as! NSNumber
            getThumbnail(path, quality, result)
        case "startCompress":
            let path = args!["path"] as! String
            let deleteOrigin = args!["deleteOrigin"] as! Bool
            startCompress(path, deleteOrigin, result)
        case "stopCompress":
            stopCompress(result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getThumbnail(_ path: String,_ quality: NSNumber,_ result: FlutterResult) {
        let asset = AVAsset(url: URL(fileURLWithPath: path.replacingOccurrences(of: "file://", with: "")))
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            let qualityResult = CGFloat(0.01 * Double(truncating: quality))
            print(qualityResult)
            let data = thumbnail.jpegData(compressionQuality: qualityResult)
            result(data)
        } catch {
            print(error)
        }
    }
    
    private func startCompress(_ path: String, _ deleteOrigin: Bool,_ result: @escaping FlutterResult) {
        let baseDirectory = NSTemporaryDirectory()
        
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        asset.tracks(withMediaType: AVMediaType.video)
        
        let fileName = url.deletingPathExtension().lastPathComponent
        let fileType = url.pathExtension
        
        let fileManager = FileManager.default
        let compressPath = "\(baseDirectory)flutter_video_compress"
        do {
            if !fileManager.fileExists(atPath: compressPath) {
                try! fileManager.createDirectory(atPath: compressPath,
                                                 withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        let destinationPath: String = "\(compressPath)/\(fileName).\(fileType)"
        let newVideoPath: NSURL = NSURL(fileURLWithPath: destinationPath)
        
        if(!isCompressing) {
            isCompressing = true
            if exporter == nil {
                exporter = AVAssetExportSession(asset: asset,
                                                presetName:AVAssetExportPresetLowQuality)!
            }
            if let export  = exporter {
                export.outputURL = newVideoPath as URL
                export.outputFileType = AVFileType.mp4
                export.shouldOptimizeForNetworkUse = true
                export.exportAsynchronously(completionHandler: {
                    if(self.stopCommand) {
                        self.isCompressing = false
                        return result(path)
                    }
                    if deleteOrigin {
                        let fileManager = FileManager.default
                        do {
                            if fileManager.fileExists(atPath: path) {
                                try fileManager.removeItem(atPath: path)
                            }
                            self.isCompressing = false
                            self.exporter = nil
                            self.stopCommand = false
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                    result(newVideoPath.relativePath)
                })
            }
        } else {
            result(FlutterError(code: "FlutterVideoCompress", message: "Already have a compression process", details: "you need to wait for the process to finish"))
        }
    }
    
    private func stopCompress(_ result: FlutterResult) {
        if exporter == nil {
            return result(FlutterError.init(code: channelName, message: "FlutterVideoCompress error", details: "FlutterVideoCompress: you don't have any thing compress"))
        }
        exporter?.cancelExport()
        stopCommand = true
    }
}
