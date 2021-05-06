#import <Cordova/CDVPlugin.h>
#import "ICoAPExchange.h"

@interface CCoap : CDVPlugin<ICoAPExchangeDelegate> {

}

- (void)request:(CDVInvokedUrlCommand *)command;
- (void)discover:(CDVInvokedUrlCommand *)command;

@end