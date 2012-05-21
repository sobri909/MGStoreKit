# MGStoreKit - A lightweight blocks based StoreKit wrapper

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

SKProducts are cached per app run, so future requests for the same SKProduct will return immediately within the same run loop. 

## Purchase a product

```objc
NSString *itemKey = @"com.bigpaua.CoolApp.CoolFeature";
[[MGStoreKit store] purchaseProduct:itemKey success:^(NSString *productId) {

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

## License

Copyright 2012, Matt Greenfield  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation 
 and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
