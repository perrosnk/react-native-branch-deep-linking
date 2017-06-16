//
//  RNBranchConfig.m
//  Pods
//
//  Created by Jimmy Dee on 6/7/17.
//
//

#import <React/RCTLog.h>

#import "RNBranchConfig.h"

NSString * _Nonnull const RNBranchConfigDebugModeOption = @"debugMode";
NSString * _Nonnull const RNBranchConfigLiveKeyOption = @"liveKey";
NSString * _Nonnull const RNBranchConfigTestKeyOption = @"testKey";
NSString * _Nonnull const RNBranchConfigUseTestInstanceOption = @"useTestInstance";

@interface RNBranchConfig()
@property (nonatomic) NSDictionary *configuration;
@property (nonatomic, readonly) NSData *configFileContents;
@property (nonatomic) NSURL *configFileURL;
@end

@implementation RNBranchConfig

+ (RNBranchConfig * _Nonnull)instance
{
    static RNBranchConfig *_instance;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        _instance = [[RNBranchConfig alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self findConfigFile];
        [self loadConfigFile];
    }
    return self;
}

- (void)loadConfigFile
{
    NSData *data = self.configFileContents;
    if (!data) return;

    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!object || error) {
        RCTLogError(@"Failed to parse branch.json. Error: %@", error.localizedDescription);
        return;
    }

    if (![object isKindOfClass:NSDictionary.class]) {
        RCTLogError(@"Contents of branch.json should be a JSON object.");
        return;
    }

    self.configuration = object;
}

- (NSData *)configFileContents
{
    if (!self.configFileURL) return nil;
    RCTLogInfo(@"Loading %@", self.configFileURL.pathComponents.lastObject);

    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:self.configFileURL options:0 error:&error];
    if (!data || error) {
        RCTLogError(@"Failed to load %@. Error: %@", self.configFileURL, error.localizedDescription);
        return nil;
    }
    return data;
}

- (void)findConfigFile
{
    if (self.configFileURL) return;

    NSURL *configFileURL;
    NSBundle *mainBundle = NSBundle.mainBundle;
#ifdef DEBUG
    configFileURL = [mainBundle URLForResource:@"branch.debug" withExtension:@"json"] ?: [mainBundle URLForResource:@"branch" withExtension:@"json"];
    if (!configFileURL) {
        RCTLogInfo(@"Could not find branch.debug.json or branch.json in app bundle.");
        return;
    }
#else
    configFileURL = [mainBundle URLForResource:@"branch" withExtension:@"json"];
    if (!configFileURL) {
        // probably suppressed in a Release build anyway
        RCTLogInfo(@"Could not find branch.json in app bundle.");
        return;
    }
#endif // DEBUG

    self.configFileURL = configFileURL;
}

- (BOOL)debugMode
{
    NSNumber *number = self[RNBranchConfigDebugModeOption];
    return number.boolValue;
}

- (BOOL)useTestInstance
{
    NSNumber *number = self[RNBranchConfigUseTestInstanceOption];
    return number.boolValue;
}

- (NSString *)liveKey
{
    return self[RNBranchConfigLiveKeyOption];
}

- (NSString *)testKey
{
    return self[RNBranchConfigTestKeyOption];
}

- (id)objectForKey:(NSString *)key
{
    return self.configuration[key];
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    return self.configuration[key];
}

@end
