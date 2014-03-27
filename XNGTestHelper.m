//
// Copyright (c) 2014 XING AG (http://xing.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XNGTestHelper.h"
#import <XNGAPIClient/XNGOAuthHandler.h>
#import "XNGTestHelper_Private.h"

@implementation XNGTestHelper

#pragma mark - fake data

- (NSString *)fakeOAuthConsumerKey {
    return @"123";
}

- (NSString *)fakeOAuthConsumerSecret {
    return @"456";
}

#pragma mark - setup and tearDown helper

- (void)setupOAuthCredentials {
    [[XNGAPIClient sharedClient] setConsumerKey:self.fakeOAuthConsumerKey];
    [[XNGAPIClient sharedClient] setConsumerSecret:self.fakeOAuthConsumerSecret];
}

- (void)tearDownOAuthCredentials {
    [[XNGAPIClient sharedClient] setConsumerKey:nil];
    [[XNGAPIClient sharedClient] setConsumerSecret:nil];
}

- (void)setupLoggedInUserWithUserID:(NSString *)userID {
    [self.oAuthHandler saveUserID:userID
                      accessToken:@"789"
                           secret:@"456"
                          success:nil
                          failure:nil];
}

- (void)tearDownLoggedInUser {
    [self.oAuthHandler deleteKeychainEntries];
}

- (XNGOAuthHandler *)oAuthHandler {
    if (!_oAuthHandler) {
        _oAuthHandler = [[XNGOAuthHandler alloc] init];
    }

    return _oAuthHandler;
}

#pragma mark - body data helper

- (NSString *)stringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];

}

#pragma mark - oauth parameter helper

- (void)removeOAuthParametersInQueryDict:(NSMutableDictionary *)queryDict {
    for (NSString *oauthParameter in @[ @"oauth_token",
                                        @"oauth_signature_method",
                                        @"oauth_version",
                                        @"oauth_nonce",
                                        @"oauth_consumer_key",
                                        @"oauth_timestamp",
                                        @"oauth_signature" ]) {
        [queryDict removeObjectForKey:oauthParameter];
    }
}

- (NSMutableDictionary *)dictFromQueryString:(NSString *)queryString {
    NSArray *componentsArray = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *keyValueString in componentsArray) {
        NSArray *array = [keyValueString componentsSeparatedByString:@"="];
        if (array.count == 2) [dict setValue:array[1] forKey:array[0]];
    }
    return dict;
}

- (NSMutableDictionary *)dictFromJSONData:(NSData *)data {
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:&error];
    expect(error).to.beNil();
    return [dict mutableCopy];
}

#pragma mark - RunLoop hack

- (void)runRunLoopShortly {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
}

#pragma mark - wrapper call

- (void)executeCall:(void (^)())call
   withExpectations:(void (^)(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body))expectations {

    [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {

        NSMutableDictionary *query = [self dictFromQueryString:request.URL.query];

        NSMutableDictionary *body;

        NSString *contentType = [request.allHTTPHeaderFields valueForKey:@"Content-Type"];
        if ([contentType isEqualToString:@"application/json; charset=utf-8"]) {
            body = [self dictFromJSONData:request.HTTPBody];
        } else {
            NSString *bodyString = [self stringFromData:request.HTTPBody];
            body = [self dictFromQueryString:bodyString];
        }

        if (expectations) expectations(request, query, body);
    }];

    if (call) call();

    [XNGAPIClient.sharedClient.operationQueue waitUntilAllOperationsAreFinished];
}

#pragma mark - convenient methods

- (void)setup {
    // setup a fake logged in user
    [self setupOAuthCredentials];
    [self setupLoggedInUserWithUserID:@"1"];

    // stub all outgoing network requests
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return nil;
    }];
}

- (void)tearDown {
    // remove all logged in users
    [self tearDownOAuthCredentials];
    [self tearDownLoggedInUser];

    // also remove all network request stubs
    [OHHTTPStubs removeAllStubs];
}

@end
