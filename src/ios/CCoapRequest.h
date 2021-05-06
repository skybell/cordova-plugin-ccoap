//
//  CCoapRequest.h
//  Example Cordva
//
//  Created by James Timberlake on 5/5/21.
//

#import <Foundation/Foundation.h>
#import "ICoAPExchange.h"

@interface CCoapRequest : NSObject

+(ICoAPExchange* )createAndSendRequest:(NSDictionary* )requestDict withDelegate: (id<ICoAPExchangeDelegate>) delegate usingExchange: (ICoAPExchange*) exchange;

@end

