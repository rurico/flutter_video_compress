import Flutter
import UIKit
import AVFoundation

public class SwiftFlutterVideoCompressPlugin: NSObject, FlutterPlugin {
    private let channelName = "flutter_video_compress"
    private var exporter: AVAssetExportSession? = nil
    private var stopCommand = false
    private let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_video_compress", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterVideoCompressPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        switch call.method {
        case "basePath":
            result("\(NSTemporaryDirectory())flutter_video_compress")
        case "getThumbnail":
            let path = args!["path"] as! String
            let quality = args!["quality"] as! NSNumber
            let position = args!["position"] as! NSNumber
            getThumbnail(path, quality, position, result)
        case "getThumbnailWithFile":
            let path = args!["path"] as! String
            let quality = args!["quality"] as! NSNumber
            let position = args!["position"] as! NSNumber
            getThumbnailWithFile(path, quality, position, result)
        case "getMediaInfo":
            let path = args!["path"] as! String
            getMediaInfo(path, result)
        case "startCompress":
            let path = args!["path"] as! String
            let quality = args!["quality"] as! NSNumber
            let deleteOrigin = args!["deleteOrigin"] as! Bool
            startCompress(path, quality, deleteOrigin, result)
        case "stopCompress":
            stopCompress()
            result("")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initFolder()->String {
        let fileManager = FileManager.default
        let basePath = "\(NSTemporaryDirectory())flutter_video_compress"
        do {
            if !fileManager.fileExists(atPath: basePath) {
                try! fileManager.createDirectory(atPath: basePath,
                                                 withIntermediateDirectories: true, attributes: nil)
            }
        }
        return basePath
    }
    
    private func getThumbnail(_ path: String,_ quality: NSNumber,_ position: NSNumber,_ result: FlutterResult) {
        let asset = AVAsset(url: URL(fileURLWithPath: excludeFileProtocol(path)))
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        guard let track = asset.tracks(withMediaType: AVMediaType.video).first else { return }
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let timeScale = CMTimeScale(track.nominalFrameRate)
        
        let time = CMTimeMakeWithSeconds(Float64(truncating: position),preferredTimescale: timeScale)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at:time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            let qualityResult = CGFloat(0.01 * Double(truncating: quality))
            let data = thumbnail.jpegData(compressionQuality: qualityResult)
            result(data)
        }
        catch {
            result(FlutterError(code: channelName,message: "getThumbnail error",details: error))
        }
    }
    
    private func getThumbnailWithFile(_ path: String,_ quality: NSNumber,_ position: NSNumber,_ result: FlutterResult) {
        let asset = AVAsset(url: URL(fileURLWithPath: excludeFileProtocol(path)))
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        guard let track = asset.tracks(withMediaType: AVMediaType.video).first else { return }
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let timeScale = CMTimeScale(track.nominalFrameRate)
        
        let time = CMTimeMakeWithSeconds(Float64(truncating: position),preferredTimescale: timeScale)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at:time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            let qualityResult = CGFloat(0.01 * Double(truncating: quality))
            let fileName = String(path[path.lastIndex(of: "/")!..<path.lastIndex(of: ".")!])
            let url = URL(fileURLWithPath: "\(initFolder())\(fileName).jpg")
            
            let fileManger = FileManager.default
            deleteExists(url)
            
            if let data = thumbnail.jpegData(compressionQuality: qualityResult),
                !fileManger.fileExists(atPath: url.absoluteString) {
                try data.write(to: url)
                result(excludeFileProtocol(url.absoluteString))
            }
        }
        catch {
            result(FlutterError(code: channelName,message: "getThumbnail error",details: error))
        }
    }
    
    private func deleteExists(_ url:URL) {
        let fileManger = FileManager.default
        do {
            if fileManger.fileExists(atPath: url.absoluteString) {
                try fileManger.removeItem(at: url)
            }
        } catch {
            print(error)
        }
    }
    
    private func getMetaDataByTag(_ asset:AVAsset,key:String)->String {
        for item in asset.commonMetadata {
            if item.commonKey?.rawValue == key {
                return item.stringValue ?? "";
            }
        }
        return ""
    }
    
    private func getMediaInfoJson(_ path: String)->[String : Any?] {
        let url = URL(fileURLWithPath: excludeFileProtocol(path))
        let asset = AVURLAsset(url: url)
        
        guard let track = asset.tracks(withMediaType: AVMediaType.video).first else { return [:] }
        let size = track.naturalSize.applying(track.preferredTransform)
        
        let playerItem = AVPlayerItem(url: url)
        let metadataAsset = playerItem.asset
        let title = getMetaDataByTag(metadataAsset,key: "title")
        let author = getMetaDataByTag(metadataAsset,key: "author")
        let width = abs(size.width)
        let height = abs(size.height)
        let duration = asset.duration.seconds * 1000
        let filesize = track.totalSampleDataLength
        let dictionary = [
            "path":path,
            "title":title,
            "author":author,
            "width":width,
            "height":height,
            "duration":duration,
            "filesize":filesize
            ] as [String : Any?]
        return dictionary
    }
    
    private func keyValueToJson(_ keyAndValue: [String : Any?])->String {
        let data = try! JSONSerialization.data(withJSONObject: keyAndValue as NSDictionary, options: [])
        let jsonString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return jsonString! as String
    }
    
    private func getMediaInfo(_ path: String,_ result: FlutterResult) {
        let data = getMediaInfoJson(path)
        let jsonString = keyValueToJson(data)
        result(jsonString)
    }
    
    @objc private func updateProgress(timer:Timer) {
        let asset = timer.userInfo as! AVAssetExportSession
        if(!stopCommand) {
            channel.invokeMethod("updateProgress", arguments: "\(String(describing: asset.progress * 100))")
        }
    }
    
    private func getExportPreset(_ quality: NSNumber)->String {
        switch(quality) {
        case 0:
            return AVAssetExportPresetLowQuality
        case 1:
            return AVAssetExportPresetMediumQuality
        case 2:
            return AVAssetExportPresetHighestQuality
        default:
            return AVAssetExportPresetLowQuality
        }
    }
    
    private func excludeFileProtocol(_ path: String)->String {
        let path = path.replacingOccurrences(of: "file://", with: "")
        return path
    }
    
    private func startCompress(_ path: String,_ quality: NSNumber,_ deleteOrigin: Bool,_ result: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: excludeFileProtocol(path))
        let asset = AVAsset(url: url)
        asset.tracks(withMediaType: AVMediaType.video)
        
        let fileName = url.deletingPathExtension().lastPathComponent
        let fileType = url.pathExtension
        
        let destinationPath: String = "\(initFolder())/\(fileName).\(fileType)"
        let newVideoPath = URL(fileURLWithPath: destinationPath)
        deleteExists(newVideoPath)
        
        guard let exporter = AVAssetExportSession(asset: asset,
                                                  presetName:getExportPreset(quality)) else { return }
        
        exporter.outputURL = newVideoPath
        exporter.outputFileType = AVFileType.mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgress), userInfo: exporter, repeats: true)
        
        exporter.exportAsynchronously(completionHandler: {
            if(self.stopCommand) {
                timer.invalidate()
                self.stopCommand = false
                var json = self.getMediaInfoJson(path)
                json["isCancel"] = true
                let jsonString = self.keyValueToJson(json)
                return result(jsonString)
            }
            if deleteOrigin {
                timer.invalidate()
                let fileManager = FileManager.default
                do {
                    if fileManager.fileExists(atPath: path) {
                        try fileManager.removeItem(atPath: path)
                    }
                    self.exporter = nil
                    self.stopCommand = false
                }
                catch let error as NSError {
                    print(error)
                }
            }
            var json = self.getMediaInfoJson(newVideoPath.relativePath)
            json["isCancel"] = false
            let jsonString = self.keyValueToJson(json)
            result(jsonString)
        })
    }
    
    private func stopCompress() {
        exporter?.cancelExport()
        stopCommand = true
    }
}
