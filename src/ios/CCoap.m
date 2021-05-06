#import "CCoap.h"
#import "CCoapUtils.h"
#import "CCoapRequest.h"
#import <Cordova/CDVAvailability.h>

@interface CCoap() {
   ICoAPExchange *coapExchange;
   NSString* callbackId;
}
@end


@implementation CCoap

- (void)pluginInitialize {
    callbackId = @"";
}

- (void)request:(CDVInvokedUrlCommand *)command {
    NSDictionary* request = [command.arguments objectAtIndex:0];

    if (request == nil) {
        //stop here
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No request object found"];
        [self.commandDelegate sendPluginResult: result callbackId:command.callbackId];
        return;
    }

    callbackId = command.callbackId;
    coapExchange = [CCoapRequest createAndSendRequest:request withDelegate:self usingExchange:coapExchange];
}

- (void)discover:(CDVInvokedUrlCommand *)command {

}

#pragma mark - iCoAP Exchange Delegate

- (void)iCoAPExchange:(ICoAPExchange *)exchange didReceiveCoAPMessage:(ICoAPMessage *)coapMessage {
    
    @try {
        
        NSMutableDictionary* responseDict = [[NSMutableDictionary alloc] init];
        
        //return response code
        NSNumber* code = [NSNumber numberWithUnsignedLong: coapMessage.code];
        responseDict[@"code"] = code;
    
        //append payload, if exists
        if( coapMessage.payload != nil) {
            responseDict[@"payload"] = coapMessage.payload;
        }
    
        //append options
        if(coapMessage.optionDict != nil) {
            responseDict[@"options"] = coapMessage.optionDict;
        }
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:responseDict];
        
        [self.commandDelegate sendPluginResult: result callbackId:callbackId];
        
    }
    @catch(NSException* exception)  {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsString:@"Cannot create response JSON"];
        
        [self.commandDelegate sendPluginResult: result callbackId:callbackId];
    }

    
    // did you receive the expected message? then it is recommended to use the closeTransmission method
    // unless more messages are expected, like e.g. block messages, or observe messages.
    [exchange closeExchange];
}

- (void)iCoAPExchange:(ICoAPExchange *)exchange didFailWithError:(NSError *)error {
    //Handle Errors
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Exchangs has failed"];
    
    [self.commandDelegate sendPluginResult: result callbackId:callbackId];
}


- (void)iCoAPExchange:(ICoAPExchange *)exchange didRetransmitCoAPMessage:(ICoAPMessage *)coapMessage number:(uint)number finalRetransmission:(BOOL)final {
    //Received retransmission notification
    
    
}



@end
