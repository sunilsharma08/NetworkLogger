//
//  StringExtensions.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 26/01/19.
//

import Foundation

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self)
        else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
}

extension NSObject {
    
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last ?? ""
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

internal extension URLRequest {
    
    func getNSMutableURLRequest() -> NSMutableURLRequest? {
    guard let mutableRequest = (self as NSURLRequest).mutableCopy() as? NSMutableURLRequest
    else { return nil }
    return mutableRequest
    }
    
    func getCachePolicyName() -> String {
        
        switch cachePolicy {
        case .useProtocolCachePolicy:
            return "UseProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData:
            return "ReloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "ReloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad:
            return "ReturnCacheDataElseLoad"
        case .returnCacheDataDontLoad:
            return "ReturnCacheDataDontLoad"
        case .reloadRevalidatingCacheData:
            return "ReloadRevalidatingCacheData"
        default:
            return "Unknown"
        }
    }
    
    func getNetworkTypeName() -> String {
        switch networkServiceType {
        case .default:
            return "Default - Standard internet traffic"
        case .voip:
            return "VOIP traffic"
        case .video:
            return "Video traffic"
        case .background:
            return "Background traffic"
        case .voice:
            return "Voice data traffic"
        case .responsiveData:
            return "Responsive data traffic"
        case .callSignaling:
            return "Call Signaling traffic"
        default:
            return "Unknown"
        }
    }
    
    func getMimeType() -> String? {
        let contType: String? = value(forHTTPHeaderField: "Content-Type")
        if let contentType = contType, contentType.isEmpty == false {
            let components = contentType.split(separator: ";")
            if components.count > 0 {
                let mimeType = components[0].replacingOccurrences(of: ";", with: "")
                return mimeType
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension NSMutableURLRequest {
    
    func setNLFlag(value: Any) {
        URLProtocol.setProperty(value, forKey: AppConstants.NLRequestFlagKey, in: self)
    }
}

extension TimeInterval {
    
    func toReadableString() -> String {
        
        
        // Milliseconds
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        // Seconds
        let s = Int(self) % 60
        // Minutes
        let mn = (Int(self) / 60) % 60
        // Hours
        let hr = (Int(self) / 3600)
        
        var readableStr = ""
        if hr != 0 {
            readableStr += String(format: "%0.2dhr ", hr)
        }
        if mn != 0 {
            readableStr += String(format: "%0.2dmn ", mn)
        }
        if s != 0 {
            readableStr += String(format: "%0.2ds ", s)
        }
        if ms != 0 {
            readableStr += String(format: "%0.3dms ", ms)
        }
        
        return readableStr
    }
}
