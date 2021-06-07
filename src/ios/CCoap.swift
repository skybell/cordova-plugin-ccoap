//
//  CCoap.swift
//  Example Cordva
//
//  Created by James Timberlake on 5/23/21.
//

import Foundation

/*
* Notes: The @objc shows that this class & function should be exposed to Cordova.
*/
@objc(CCoap) class CCoap : CDVPlugin {
    
    var callbackId = ""
    var client: SCClient?
    
    @objc(request:) // Declare your function name.
    func request(command: CDVInvokedUrlCommand) {
        
        guard let request = command.arguments[0] as? CCoapRequest else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No request object found")
            
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            
            return
        }
        
        
        createRequest(withRequest: request, forCommand: command)

    }
    
    @objc(discover:) // Declare your function name.
    func discover(command: CDVInvokedUrlCommand) { // write the function code.
      /*
       * Always assume that the plugin will fail.
       * Even if in this example, it can't.
       */
      // Set the plugin result to fail.
      var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
      // Set the plugin result to succeed.
          pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
      // Send the function result back to Cordova.
      self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
}




extension CCoap {
    func createRequest(withRequest request:CCoapRequest, forCommand command: CDVInvokedUrlCommand){
        
        guard let port = request.getPort(),
              let host = request.getHost() else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No request object found")
            
            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
            
            return
        }
        
        
        client = SCClient(delegate: self)
        client?.sendToken = true
        client?.autoBlock1SZX = 6
        //fiddler proxy setting
        //client?.httpProxyingData = ("192.168.1.5", 8866)
        
        let requestCode = request.getRequestMethodSCCodeValue()
        let message = SCMessage(code: requestCode, type: .confirmable, payload: nil)
        
        if let payload = request.getPayload() {
            message.payload = payload.data(using: String.Encoding.utf8)
        }
        
        if let uriPath = request.getUriPath(),
           let uriData = uriPath.data(using: String.Encoding.utf8) {
            message.addOption(SCOption.uriPath.rawValue, data: uriData)
        }

        print("Options is of type \(type(of: request["options"]!))")
        for option in request.getOptions() {
            print("Options is of type \(option.description))")
            if let optionName = option["name"] as? String,
               let optionValue = option["value"] {
                
                let optionFormatString = optionName.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "-", with: "_")
                for optionType in SCOption.allValues {
                    if optionType.toString().lowercased() == optionFormatString.lowercased() {
                        var value: Data?
                        switch optionName {
                        case "Accept":
                            if let stringData = optionValue as? String {
                                value = stringData.data(using: .utf8)
                            }
                            break
                        case "Content-Format":
                            if let intData = optionValue as? Int {
                                print("Content format: \(intData)")
                                value = String(intData).data(using: .utf8)
                            }
                            break
                        case "ETag":
                            if let stringData = optionValue as? String {
                                value = stringData.data(using: .utf8)
                            }
                            break
                        case "If-None-Match":
                            if let stringData = optionValue as? String {
                                value = stringData.data(using: .utf8)
                            }
                            break
                        case "If-Match":
                            if let stringData = optionValue as? String {
                                value = stringData.data(using: .utf8)
                            }
                            break
                        default:
                            break
                        }
                        
                        if let dataValue = value {
                            message.addOption(optionType.rawValue, data:dataValue )
                        }
                    }
                }
                
                print("\(optionName) brings value type \(optionValue)")
            }
        }
        
        callbackId = command.callbackId
        client?.sendCoAPMessage(message, hostName:host,  port:port)
    }

}


extension CCoap : SCClientDelegate {
    func swiftCoapClient(_ client: SCClient, didReceiveMessage message: SCMessage) {
        var responseDict = [String:AnyHashable]()
        
        if let pay = message.payload {
            if let string = NSString(data: pay as Data, encoding:String.Encoding.utf8.rawValue) {
                let payloadstring = String(string)
                responseDict["payload"] = payloadstring
            }
        }
        
        responseDict["code"] = message.code.toRawValue()
        responseDict["options"] = message.options
        
        print("response dictionary: \(responseDict)")
        
        // Set the plugin result to fail.
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: responseDict)
        
        print("communication has been received")
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
        
    }
    
    func swiftCoapClient(_ client: SCClient, didFailWithError error: NSError) {
        print("Exchange with error \(error.debugDescription)")
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.debugDescription)
        
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }
    
    func swiftCoapClient(_ client: SCClient, didSendMessage message: SCMessage, number: Int) {

    }
    
}
