//
// MGStoreKit.h
//
// Created by Matt Greenfield on 7/08/11.
// Copyright Big Paua 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^ProductsCallback)(NSArray *products);
typedef void (^PurchaseCallback)(NSString *productId);

@interface MGStoreKit : NSObject
        <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (MGStoreKit *)store;

// fetch products data
- (void)requestProductsData:(NSSet *)products
                   callback:(ProductsCallback)callback;

// confirm permission before making a purchase
- (BOOL)canMakePayments;

// start the purchase
- (void)purchaseProduct:(NSString *)productId
                success:(PurchaseCallback)callback
                 failed:(PurchaseCallback)failed;

// restore previous purchases
- (void)restore:(ProductsCallback)callback;

@property (nonatomic, retain) NSMutableDictionary *cachedProducts;

@end
