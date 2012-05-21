//
// MGStoreKit.m
//
// Created by Matt Greenfield on 7/08/11.
// Copyright Big Paua 2012. All rights reserved.
//

#import "MGStoreKit.h"

@interface MGStoreKit ()

@property (nonatomic, retain) SKProductsRequest *productsRequest;
@property (nonatomic, copy) ProductsCallback productsCallback;
@property (nonatomic, copy) PurchaseCallback purchaseCallback;
@property (nonatomic, copy) ProductsCallback restoreCallback;
@property (nonatomic, copy) PurchaseCallback failedCallback;

@end

@implementation MGStoreKit

@synthesize cachedProducts, productsRequest;
@synthesize productsCallback, purchaseCallback, failedCallback, restoreCallback;

- (id)init {
    self = [super init];
    self.cachedProducts = [NSMutableDictionary dictionary];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return self;
}

- (void)requestProductsData:(NSSet *)keys
                   callback:(ProductsCallback)callback {
    BOOL haveAllCached = YES;
    NSMutableArray *have = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *key in keys) {
        SKProduct *product = [self.cachedProducts objectForKey:key];
        if (![self.cachedProducts objectForKey:key]) {
            haveAllCached = NO;
            break;
        }
        [have addObject:product];
    }
    if (haveAllCached && callback) {
        callback(have);
        return;
    }
    self.productsCallback = callback;
    self.productsRequest =
            [[SKProductsRequest alloc] initWithProductIdentifiers:keys];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

- (void)purchaseProduct:(NSString *)productId
                success:(PurchaseCallback)callback
                 failed:(PurchaseCallback)failed {
    self.purchaseCallback = callback;
    self.failedCallback = failed;
    SKProduct *product = [self.cachedProducts objectForKey:productId];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
    if ([response.invalidProductIdentifiers count]) {
        for (NSString *invalidProductId in response.invalidProductIdentifiers) {
            NSLog(@"invalid product key:%@", invalidProductId);
        }
        if (self.productsCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.productsCallback(nil);
            });
        }
        return;
    }
    if (![response.products count]) {
        NSLog(@"no products in response");
        if (self.productsCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.productsCallback(nil);
            });
        }
        return;
    }
    for (SKProduct *product in response.products) {
        [self.cachedProducts
                setObject:product forKey:product.productIdentifier];
    }
    if (self.productsCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.productsCallback(response.products);
        });
    }
}

- (void)restore:(ProductsCallback)callback {
    self.restoreCallback = callback;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)
paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSMutableArray *restored = [NSMutableArray array];
    for (SKPaymentTransaction *transaction in queue.transactions) {
        if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            [restored
                    addObject:transaction.originalTransaction.payment.productIdentifier];
        }
    }
    self.restoreCallback(restored);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchased:
            if (self.purchaseCallback) {
                self.purchaseCallback(transaction.payment.productIdentifier);
            }
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        case SKPaymentTransactionStateRestored:
            if (self.purchaseCallback) {
                self.purchaseCallback(
                        transaction.originalTransaction.payment.productIdentifier);
            }
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        case SKPaymentTransactionStateFailed:
            NSLog(@"%@", transaction.error);
            if (self.failedCallback) {
                self.failedCallback(transaction.payment.productIdentifier);
            }
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        default:
            break;
        }
    }
}

@end
