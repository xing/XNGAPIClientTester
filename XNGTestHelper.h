#import <Foundation/Foundation.h>

#import <OHHTTPStubs/OHHTTPStubs.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#import "XNGAPIClient.h"

@interface XNGTestHelper : NSObject

+ (NSString *)fakeOAuthConsumerKey;
+ (NSString *)fakeOAuthConsumerSecret;

+ (void)setupOAuthCredentials;
+ (void)tearDownOAuthCredentials;

+ (void)setupLoggedInUserWithUserID:(NSString *)userID;
+ (void)tearDownLoggedInUser;

+ (void)assertAndRemoveOAuthParametersInQueryDict:(NSMutableDictionary *)queryDict;

+ (void)executeCall:(void (^)())call
    withExpectations:(void (^)(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body))expectations;

@end
