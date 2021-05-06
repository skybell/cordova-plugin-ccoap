
#import "CCoapUtils.h"

@implementation CCoapUtils


+(NSDictionary *) getErrorObject: (NSError*) error {
    if(error == nil) {
        return [ [NSDictionary alloc]
                               initWithObjectsAndKeys :
                                 @"Unkown Error", @"errorType",
                                 @"false", @"success",
                                 nil
        ];
    }

    return  [ [NSDictionary alloc]
                               initWithObjectsAndKeys :
                                 @"iOS Error", @"errorType",
                                 [error localizedDescription], @"errorMessage"
                                 @"false", @"success",
                                 nil
    ];
}

@end
