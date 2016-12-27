//
//  TPRDataManager.m
//  ThirdpresenceMopubMediation
//
//  Created by Marko Okkonen on 14/12/16.
//  Copyright © 2016 thirdpresence. All rights reserved.
//

#import "TPRDataManager.h"

@interface TPRDataManager ()
@end

@implementation TPRDataManager

+ (id)sharedManager {
    static TPRDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        self.targeting = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
