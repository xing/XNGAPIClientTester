#import "XNGTestHelper.h"
#import "XNGOAuthHandler.h"

@interface XNGTestHelper ()

+ (NSString *)stringFromData:(NSData *)data;
+ (NSMutableDictionary *)dictFromQueryString:(NSString *)queryString;
+ (void)runRunLoopShortly;

@end

@implementation XNGTestHelper

#pragma mark - fake data

+ (NSString *)fakeOAuthConsumerKey {
    return @"123";
}

+ (NSString *)fakeOAuthConsumerSecret {
    return @"456";
}

#pragma mark - setup and teardown helper

+ (void)setupOAuthCredentials {
    [[XNGAPIClient sharedClient] setConsumerKey:[self fakeOAuthConsumerKey]];
    [[XNGAPIClient sharedClient] setConsumerSecret:[self fakeOAuthConsumerSecret]];
}

+ (void)tearDownOAuthCredentials {
    [[XNGAPIClient sharedClient] setConsumerKey:nil];
    [[XNGAPIClient sharedClient] setConsumerSecret:nil];
}

+ (void)setupLoggedInUserWithUserID:(NSString *)userID {
    XNGOAuthHandler *oauthHandler = [[XNGOAuthHandler alloc] init];
    [oauthHandler saveUserID:userID
                 accessToken:@"789"
                      secret:@"456"
                     success:nil
                     failure:nil];
}

+ (void)tearDownLoggedInUser {
    XNGOAuthHandler *oauthHandler = [[XNGOAuthHandler alloc] init];
    [oauthHandler deleteKeychainEntries];
}

#pragma mark - body data helper

+ (NSString *)stringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];

}

#pragma mark - oauth parameter helper

+ (void)assertAndRemoveOAuthParametersInQueryDict:(NSMutableDictionary *)queryDict {
    for (NSString *oauthParameter in @[ @"oauth_token",
                                        @"oauth_signature_method",
                                        @"oauth_version",
                                        @"oauth_nonce",
                                        @"oauth_consumer_key",
                                        @"oauth_timestamp",
                                        @"oauth_signature" ]) {
        expect([queryDict valueForKey:oauthParameter]).toNot.beNil;
        [queryDict removeObjectForKey:oauthParameter];
    }
}

+ (NSMutableDictionary *)dictFromQueryString:(NSString *)queryString {
    NSArray *componentsArray = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *keyValueString in componentsArray) {
        NSArray *array = [keyValueString componentsSeparatedByString:@"="];
        if (array.count == 2) [dict setValue:array[1] forKey:array[0]];
    }
    return dict;
}

#pragma mark - runloop hackery

+ (void)runRunLoopShortly {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
}

#pragma mark - wrapper call

+ (void)executeCall:(void (^)())call
    withExpectations:(void (^)(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body))expectations {

    [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {

        NSMutableDictionary *query = [XNGTestHelper dictFromQueryString:request.URL.query];

        NSString *bodyString = [XNGTestHelper stringFromData:request.HTTPBody];
        NSMutableDictionary *body = [XNGTestHelper dictFromQueryString:bodyString];

        if (expectations) expectations(request, query, body);
    }];

    if (call) call();

    [XNGTestHelper runRunLoopShortly];
}

@end
