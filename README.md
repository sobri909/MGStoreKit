# MGStoreKit - A lightweight blocks based StoreKit wrapper for in app purchases

All requests are asynchronous. Success and failure callbacks are executed on the main thread.

## Fetch product data

```objc
NSString *itemKey = @"com.bigpaua.CoolApp.CoolFeature";
[[MGStoreKit store] requestProductsData:[NSSet setWithObject:itemKey]
    callback:^(NSArray *products) {
        for (SKProduct *product in products) {
            NSLog(@"Product Name:%@", product.localizedTitle);
            NSLog(@"Product Price:%@", product.price);
        }
    }];
```

SKProducts are cached per app run, so future requests for the same SKProduct will return return immediately, within the same run loop. 

## Purchase a product

```objc
[[MGStoreKit store] purchaseProduct:loops2IAPKey success:^(NSString *productId) {

    // It's your responsibility to save the purchases to keychain, Core Data, 
    // or elsewhere. As a lightweight wrapper, MGStoreKit leaves these app 
    // level details up to you.
    
    NSLog(@"Purchased:%@", productId);

} failed:^(NSString *productId) {

    // Failure is most likely the user changing their mind and tapping Cancel.
    
    NSLog(@"Failed:%@", productId);
}];
```

## Restore previous purchases

```objc
[[MGStoreKit store] restore:^(NSArray *restored) {
    for (NSString *productKey in restored) {

        // It's your responsibility to save the restored purchases to keychain, 
        // Core Data, or elsewhere. As a lightweight wrapper, MGStoreKit leaves 
        // these app level details up to you.

        NSLog(@"restored:%@", productKey);
    }
}];
```

