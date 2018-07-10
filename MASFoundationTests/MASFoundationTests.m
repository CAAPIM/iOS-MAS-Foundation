//
//  MASFoundationTests.m
//  MASFoundationTests
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MASFoundation.h"
#import "MASModelService.h"
#import "MASAccessService.h"

typedef void (^RequestComplete)(NSHTTPURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error);

@interface MASFoundationTests : XCTestCase

@end


@implementation MASFoundationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

# pragma mark - Custom

- (void)makeRequestTest:(RequestComplete)completion {
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"GET"];
    [builder setEndPoint:@"/digital/v1/listas/bancos/"];
    
    MASRequest *request = [builder build];
    [MAS invoke:request completion:completion];
}

# pragma mark - Tests

- (void)testMASMustPass {
    // This is an example of a functional test case.
    
    RequestComplete whenCompleteRequest = ^(NSHTTPURLResponse * _Nullable response,
                                            id  _Nullable responseObject,
                                            NSError * _Nullable error) {
        if (error) {
            NSLog(@"\n\nDeu erro: %@\n\n", error.localizedDescription);
            XCTAssert(NO, @"Fail");
        }
        
        NSLog(@"\n\nSem erro: %@\n\n", responseObject);
        XCTAssert(YES, @"\n\nInicializado com sucesso!");
    };
    
    [MAS start:^(BOOL completed, NSError * _Nullable error) {
        if (completed) {
            if (!error) {
                NSLog(@"\n\nMAS start completed");
                [self makeRequestTest:whenCompleteRequest];
            }
        }
        
        if (error) {
            NSLog(@"\n\nDeu erro: %@", error.localizedDescription);
            XCTAssert(NO, @"Fail");
        }
    }];
}

- (void)testRegister {
    [[MASModelService sharedService] registerApplication:^(BOOL completed, NSError *error) {
        
        //
        //  If the client registration was successful, perform id_token authentication
        //
        if (completed && !error)
        {
            NSString *jwt = [MASAccessService sharedService].currentAccessObj.idToken;
            NSString *tokenType = [MASAccessService sharedService].currentAccessObj.idTokenType;
            
            [MASUser loginWithIdToken:jwt tokenType:tokenType completion:^(BOOL completed, NSError * _Nullable error) {
                
                XCTAssert(YES,  @"\n\nTudo certo!");
            }];
        }
    }];
}

@end
