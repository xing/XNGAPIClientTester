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

#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <XNGAPIClientTester/XNGTestHelper.h>
#import <XNGAPIClient/XNGOAuthHandler.h>
#import <XNGAPIClientTester/XNGTestHelper_Private.h>
#import "XNGTestHelper_Private.h"

@interface XNGAPIClientTesterTests : XCTestCase

@end

@implementation XNGAPIClientTesterTests

#pragma mark - OAuthCredentials

- (void)testFakeOAuthConsumerKey {
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];
    expect(classUnderTest.fakeOAuthConsumerKey).to.beKindOf(NSString.class);
    expect(classUnderTest.fakeOAuthConsumerKey.length).to.beGreaterThan(0);
}

- (void)testFakeOAuthConsumerSecret {
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];
    expect(classUnderTest.fakeOAuthConsumerSecret).to.beKindOf(NSString.class);
    expect(classUnderTest.fakeOAuthConsumerSecret.length).to.beGreaterThan(0);
}

- (void)testSetupOAuthCredentials {
    [self removeOAuthCredentialsFromAPIClient];

    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];
    [classUnderTest setupOAuthCredentials];

    NSString *consumerKey = [[XNGAPIClient sharedClient] valueForKey:@"key"];
    NSString *consumerSecret = [[XNGAPIClient sharedClient] valueForKey:@"secret"];

    expect(consumerKey).notTo.beNil();
    expect(consumerKey).to.beKindOf([NSString class]);
    expect(consumerKey.length).to.beGreaterThan(0);

    expect(consumerSecret).notTo.beNil();
    expect(consumerSecret).to.beKindOf([NSString class]);
    expect(consumerSecret.length).to.beGreaterThan(0);
}

- (void)testTearDownOAuthCredentials {
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];
    [classUnderTest tearDownOAuthCredentials];

    NSString *consumerKey = [[XNGAPIClient sharedClient] valueForKey:@"key"];
    NSString *consumerSecret = [[XNGAPIClient sharedClient] valueForKey:@"secret"];

    expect(consumerKey).to.beNil();
    expect(consumerSecret).to.beNil();
}

- (void)removeOAuthCredentialsFromAPIClient {
    [[XNGAPIClient sharedClient] setValue:@"" forKey:@"key"];
    [[XNGAPIClient sharedClient] setValue:@"" forKey:@"secret"];
}

#pragma mark - OAuthHandler

- (void)testSetupLoggedInUserWithUserID {
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];

    id oAuthHandlerMock = [OCMockObject mockForClass:[XNGOAuthHandler class]];
    [[oAuthHandlerMock expect] saveUserID:@"1234567"
                              accessToken:@"789"
                                   secret:@"456"
                                  success:nil
                                  failure:nil];

    id classUnderTestMock = [OCMockObject partialMockForObject:classUnderTest];
    [[[classUnderTestMock stub] andReturn:oAuthHandlerMock] oAuthHandler];

    [classUnderTestMock setupLoggedInUserWithUserID:@"1234567"];
    [oAuthHandlerMock verify];
}

- (void)testTearDownLoggedInUser {
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];

    id oAuthHandlerMock = [OCMockObject mockForClass:[XNGOAuthHandler class]];
    [[oAuthHandlerMock expect] deleteKeychainEntries];

    id classUnderTestMock = [OCMockObject partialMockForObject:classUnderTest];
    [[[classUnderTestMock stub] andReturn:oAuthHandlerMock] oAuthHandler];

    [classUnderTestMock tearDownLoggedInUser];
    [oAuthHandlerMock verify];
}

- (void)testOAuthHandlerGetter {
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];
    expect(classUnderTest.oAuthHandler).notTo.beNil();
    expect(classUnderTest.oAuthHandler).to.beKindOf(XNGOAuthHandler.class);
}

#pragma mark - oauth parameter helper

- (void)testRemoveOAuthParametersInQueryDict {
    NSDictionary *dict = @{@"oauth_token": @"token",
            @"oauth_signature_method": @"signature_method",
            @"oauth_version": @"version",
            @"oauth_nonce": @"nonce",
            @"oauth_consumer_key": @"consumer_key",
            @"oauth_timestamp": @"timestamp",
            @"oauth_signature": @"signature",
            @"random_key": @"key"};
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];
    [classUnderTest removeOAuthParametersInQueryDict:queryDict];

    expect(queryDict.allKeys).to.haveCountOf(1);
    expect(queryDict[@"random_key"]).to.equal(@"key");
}

#pragma mark - Foundation helper

- (void)testDictFromQueryString {
    NSString *queryString = @"?key1=value1&key2=value2";
    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];

    NSMutableDictionary *dictionary = [classUnderTest dictFromQueryString:queryString];
    expect(dictionary.allKeys).to.haveCountOf(2);
    expect(dictionary[@"key1"]).to.equal(@"value1");
    expect(dictionary[@"key2"]).to.equal(@"value2");
}

- (void)testDictFromJSONData {
    NSDictionary *dict = @{@"key1": @"value1", @"key2": @"value2"};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    expect(jsonData).notTo.beNil();

    XNGTestHelper *classUnderTest = [[XNGTestHelper alloc] init];
    NSDictionary *parsedDict = [classUnderTest dictFromJSONData:jsonData];
    expect(parsedDict.allKeys).to.haveCountOf(2);
    expect(parsedDict[@"key1"]).to.equal(@"value1");
    expect(parsedDict[@"key2"]).to.equal(@"value2");
}

@end
