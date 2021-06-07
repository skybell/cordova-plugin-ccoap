//
//  File.swift
//  Example Cordva (iOS)
//
//  Created by James Timberlake on 5/24/21.
//

import Foundation


typealias CCoapRequest = [String:Any]

extension CCoapRequest {
    
    func getHost() -> String? {
        guard let uri = self["uri"] as? String,
              let url = URL(string: uri),
              let host = url.host else {
            return nil
        }
        
        return host
    }
 
    func getPort() -> UInt16? {
        guard let uri = self["uri"] as? String,
              let url = URL(string: uri),
              let port = url.port else {
            //defaut port
            return nil
        }
        
        return UInt16(port)
    }
    
    func getPayload() -> String? {
        guard let payload = self["payload"] as? String,
              payload != "" else {
            return nil
        }
        
        return payload
    }
    
    func getOptions() -> [[String:AnyHashable]] {
        guard let options = self["options"] as? [[String:AnyHashable]] else {
            return [[String:AnyHashable]]()
        }
    
        return options
    }
    
    func getUriPath() -> String? {
        guard let uri = self["uri"] as? String,
              let url = URL(string: uri) else {
            //defaut port
            return nil
        }
        
        return url.path.replacingOccurrences(of: "/", with: "")
    }
    
    func getRequestMethodSCCodeValue() -> SCCodeValue {
        guard let method = self["method"] as? String else {
            print("")
            return SCCodeValue(classValue: 0, detailValue: 01)!
        }
        
        switch method.lowercased() {
        case "post":
            return SCCodeValue(classValue: 0, detailValue: 02)!
        case "put":
            return SCCodeValue(classValue: 0, detailValue: 03)!
        case "delete":
            return SCCodeValue(classValue: 0, detailValue: 04)!
        default:
            return SCCodeValue(classValue: 0, detailValue: 01)!
        }
    }
}
