import Flutter
import UIKit

public class SwiftFlutterVideoCompressPlugin: NSObject, FlutterPlugin {
  private let channelName = "flutter_video_compress"
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
    case "compressVideo":
      let path = args!["path"] as! String
      let deleteOrigin = args!["deleteOrigin"] as! Bool
      compressVideo(path, deleteOrigin, result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func getThumbnail(_ path: String,_ quality: NSNumber,_ result: FlutterResult) {
    let asset = AVAsset(url: URL(fileURLWithPath: path))
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
  
  private func compressVideo(_ path: String, _ deleteOrigin: Bool,_ result: @escaping FlutterResult) {
    let baseDirectory = NSTemporaryDirectory()
    
    let url = URL(fileURLWithPath: path)
    let asset = AVAsset(url: url)
    asset.tracks(withMediaType: AVMediaType.video)
    
    let fileName = url.lastPathComponent.replacingOccurrences(of: ".MOV", with: "")
    
    let fileManager = FileManager.default
    let compressPath = "\(baseDirectory)flutter_video_compress"
    do {
      if !fileManager.fileExists(atPath: compressPath) {
        try! fileManager.createDirectory(atPath: compressPath,
                                         withIntermediateDirectories: true, attributes: nil)
      }
    }
    
    let destinationPath: String = "\(compressPath)/\(fileName).mp4"
    let newVideoPath: NSURL = NSURL(fileURLWithPath: destinationPath)
    let exporter = AVAssetExportSession(asset: asset,
                                        presetName:AVAssetExportPresetLowQuality)!
    exporter.outputURL = newVideoPath as URL
    exporter.outputFileType = AVFileType.mp4
    exporter.shouldOptimizeForNetworkUse = true
    exporter.exportAsynchronously(completionHandler: {
      if deleteOrigin {
        let fileManager = FileManager.default
        do {
          if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
          }
        } catch let error as NSError {
          print(error)
        }
      }
      result(newVideoPath.relativePath)
    })
  }
}
