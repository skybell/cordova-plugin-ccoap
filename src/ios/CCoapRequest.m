//
//  CCoapRequest.m
//  Example Cordva
//
//  Created by James Timberlake on 5/5/21.
//

#import <Foundation/Foundation.h>
#import "CCoapRequest.h"

@implementation CCoapRequest

+(ICoAPExchange* )createAndSendRequest:(NSDictionary* )requestDict withDelegate: (id<ICoAPExchangeDelegate>) delegate usingExchange: (ICoAPExchange*) exchange{
    
    BOOL confirmable = YES;
    NSUInteger requestMethod = [CCoapRequest getRequestMethodFromDictionay:requestDict];
    BOOL sendToken = YES;
    NSString* payload = [CCoapRequest getPayloadFrmDictionary:requestDict];
    NSString* host = [CCoapRequest getHostFromDictionary:requestDict];//yup
    UInt8 port = [[CCoapRequest portForUri:host] unsignedIntValue];

    ICoAPMessage* message = [[ICoAPMessage alloc] initAsRequestConfirmable:confirmable requestMethod:requestMethod sendToken:sendToken payload:payload];
    
    //append query
    NSString* query = [CCoapRequest getQueryForUri:host];
    if (query != nil) {
        [message addOption:IC_URI_QUERY withValue:query];
    }
    
    //append options
    NSArray* options = [requestDict objectForKey:@"options"];
    if( options != nil ) {
        for (NSDictionary* option in options) {
            NSString* name = [option objectForKey:@"name"];
            
            if ([name isEqualToString:@"Accept"]) {
                NSString* mimeType = [option objectForKey:@"value"];
                [message addOption:IC_ACCEPT withValue:mimeType];
            } else if ([name isEqualToString:@"Content-Format"]) {
                NSString* contentFormat = [option objectForKey:@"value"];
                [message addOption:IC_CONTENT_FORMAT withValue:contentFormat];
            } else if ([name isEqualToString:@"ETag"]) {
                NSString* eTag = [option objectForKey:@"value"];
                [message addOption:IC_ETAG withValue:eTag];
            } else if ([name isEqualToString:@"If-None-Match"]) {
                NSString* noneMatch = [option objectForKey:@"value"];
                [message addOption:IC_IF_NONE_MATCH withValue:noneMatch];
            } else if ([name isEqualToString:@"If-Match"]) {
                NSString* match = [option objectForKey:@"value"];
                [message addOption:IC_IF_MATCH withValue:match];
            } else {
                @throw [NSException exceptionWithName:@"INVALID ARGUMENT" reason:@"Unkown option" userInfo:nil];
            }
        }
    }
    
    if (exchange == nil) {
        exchange = [[ICoAPExchange alloc] initAndSendRequestWithCoAPMessage:message toHost:host port:port delegate:delegate];
    } else {
        [exchange sendRequestWithCoAPMessage:message toHost:host port:port];
    }
    return exchange;
}

+(NSUInteger) getRequestMethodFromDictionay: (NSDictionary*) req {
    NSString* method = [req objectForKey:@"method"];
    if ([method isEqualToString:@"post"]) {
        return IC_POST;
    } else if ([method isEqualToString:@"put"]) {
        return IC_PUT;
    } else if ([method isEqualToString:@"delete"]) {
        return IC_DELETE;
    } else {
        return IC_GET;
    }
}

+(NSString* ) getPayloadFrmDictionary: (NSDictionary* ) req {
    NSString* payload = [req objectForKey:@"payload"];
    return payload == nil ? @"" : payload;
}

+(NSString* ) getHostFromDictionary: (NSDictionary* )req {
    NSString* host = [req objectForKey:@"uri"];
    return host == nil ? @"" : host;
}

+(NSNumber*) portForUri: (NSString* )uri{
    return [[[NSURL alloc] initWithString:uri] port];
}

+(NSString* ) getQueryForUri: (NSString* )uri{
    return [[[NSURL alloc] initWithString:uri] query];
}

@end
