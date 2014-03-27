XINGAPIClientTester
===================

[![Build Status](https://travis-ci.org/xing/XINGAPIClientTester.svg)](https://travis-ci.org/xing/XINGAPIClientTester)

The client tester for the XINGAPIClient.

## Installation using CocoaPods

Add the `XNGAPIClientTester` pod to your Podfiles unit test target.

Example:

```ruby
target 'UnitTests', :exclusive => true do
  pod 'XNGAPIClientTester', '~> 0.0.3'
end
```

## Example usage

```objective-c
- (void)setUp {
    [super setUp];

	self.testHelper = [[XNGTestHelper alloc] init];
	[self.testHelper setup];
}

- (void)tearDown {
    [super tearDown];
    [self.testHelper tearDown];
}

- (void)testGetNetworkFeed {
    [self.testHelper executeCall:^{
         // make a call using the XNGAPIClient
         [[XNGAPIClient sharedClient] getNetworkFeedUntil:nil
                                               userFields:nil
                                                  success:nil
                                                  failure:nil];
     } withExpectations:^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         // called when the stubbed response comes in
         // this is the place where you should test your host, path and HTTP method
         expect(request.URL.host).to.equal(@"www.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/network_feed");
         expect(request.HTTPMethod).to.equal(@"GET");

         // remove all OAuth parameters
         [self.testHelper removeOAuthParametersInQueryDict:query];


         // test and remove a key from the query
         // TODO: export this in a helper method
         expect([query valueForKey:@"until"]).to.equal(@"1");
         [query removeObjectForKey:@"until"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         // assure that the query is empty
         expect([query allKeys]).to.haveCountOf(0);

         // just the same as in the query
         expect([body allKeys]).to.haveCountOf(0);
     }];
}
```
