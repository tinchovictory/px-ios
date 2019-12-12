//
//  MainExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MainExamplesViewController.h"
#import "ExampleUtils.h"

#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"
#import "PaymentMethodPluginConfigViewController.h"
#import "PaymentPluginViewController.h"
#import "MLMyMPPXTrackListener.h"

#ifdef PX_PRIVATE_POD
    @import MercadoPagoSDKV4;
#else
    @import MercadoPagoSDK;
#endif

@implementation MainExamplesViewController

- (IBAction)checkoutFlow:(id)sender {

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;

    self.pref = nil;

    // Setear una preferencia hecha a mano
    [self setCheckoutPref];
    [self setCheckoutPrefAdditionalInfo];


    //PROCESADORA
    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"APP_USR-d1c95375-5137-4eb7-868e-da3ca8067d79" checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];

    //PAGO NORMAL
//    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"APP_USR-c4f42ada-0fea-42a1-9b13-31e67096dcd3" preferenceId:@"272097319-a9040a88-5971-4fcd-92d5-6eeb4612abce"];

    //ACCESS TOKEN BRASIL
    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-1505-092415-b89a7cdcec6cc6c3916deab0c56c7136-472129472"];

    //ACCESS TOKEN ARGENTINO
    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-7092-091314-cc8f836a12b9bf78b16e77e4409ed873-470735636"];

    // AdvancedConfig
    PXAdvancedConfiguration* advancedConfig = [[PXAdvancedConfiguration alloc] init];
    [advancedConfig setExpressEnabled:YES];
//    [advancedConfig setProductIdWithId:@"bh31umv10flg01nmhg60"];

    PXDiscountParamsConfiguration* disca = [[PXDiscountParamsConfiguration alloc] initWithLabels:[NSArray arrayWithObjects: @"1", @"2", nil] productId:@"bh31umv10flg01nmhg60"];
    [advancedConfig setDiscountParamsConfiguration: disca];

    PXTrackingConfiguration *trackingConfig = [[PXTrackingConfiguration alloc] initWithTrackListener: self flowName:@"instore" flowDetails:nil sessionId:@"3783874"];
    [self.checkoutBuilder setTrackingConfigurationWithConfig: trackingConfig];

    // Add theme to advanced config.
//    MeliTheme *meliTheme = [[MeliTheme alloc] init];
//    [advancedConfig setTheme:meliTheme];

    MPTheme *mpTheme = [[MPTheme alloc] init];
    [advancedConfig setTheme:mpTheme];

    // Add ReviewConfirm configuration to advanced config.
    [advancedConfig setReviewConfirmConfiguration: [self getReviewScreenConfiguration]];

    // Add ReviewConfirm Dynamic views configuration to advanced config.
    [advancedConfig setReviewConfirmDynamicViewsConfiguration:[self getReviewScreenDynamicViewsConfigurationObject]];

    // Add ReviewConfirm Dynamic View Controller configuration to advanced config.
//    TestComponent *dynamicViewControllersConfigObject = [self getReviewScreenDynamicViewControllerConfigurationObject];
//    [advancedConfig setDynamicViewControllersConfiguration: [NSArray arrayWithObjects: dynamicViewControllersConfigObject, nil]];
//    [advancedConfig setReviewConfirmDynamicViewsConfiguration:[self getReviewScreenDynamicViewsConfigurationObject]];

    // Add PaymentResult configuration to advanced config.
    [advancedConfig setPaymentResultConfiguration: [self getPaymentResultConfiguration]];

    // Set advanced comnfig
    [self.checkoutBuilder setAdvancedConfigurationWithConfig:advancedConfig];


    // CDP color.
    //[self.mpCheckout setDefaultColor:[UIColor colorWithRed:0.49 green:0.17 blue:0.55 alpha:1.0]];

    [self.checkoutBuilder setLanguage:@"es"];

    // Add custom translation objc-compatible example.

    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyTotal_to_pay_onetap withTranslation:@"Total row en onetap"];

    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyPay_button withTranslation:@"Enviar dinero"];

    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyPay_button_progress withTranslation:@"Enviado dinero"];

    MercadoPagoCheckout *mpCheckout = [[MercadoPagoCheckout alloc] initWithBuilder:self.checkoutBuilder];

    //[mpCheckout startWithLazyInitProtocol:self];
    [mpCheckout startWithLazyInitProtocol:self];
}

// ReviewConfirm
-(PXReviewConfirmConfiguration *)getReviewScreenConfiguration {
    PXReviewConfirmConfiguration *config = [TestComponent getReviewConfirmConfiguration];
    return config;
}

// ReviewConfirm Dynamic Views Configuration Object
-(TestComponent *)getReviewScreenDynamicViewsConfigurationObject {
    TestComponent *config = [TestComponent getReviewConfirmDynamicViewsConfiguration];
    return config;
}

// ReviewConfirm Dynamic View Controller Configuration Object
-(TestComponent *)getReviewScreenDynamicViewControllerConfigurationObject {
    TestComponent *config = [TestComponent getReviewConfirmDynamicViewControllerConfiguration];
    return config;
}


// PaymentResult
-(PXPaymentResultConfiguration *)getPaymentResultConfiguration {
    PXPaymentResultConfiguration *config = [TestComponent getPaymentResultConfiguration];
    return config;
}

// Procesadora
-(PXPaymentConfiguration *)getPaymentConfiguration {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];
    PaymentPluginViewController *paymentProcessorPlugin = [storyboard instantiateViewControllerWithIdentifier:@"paymentPlugin"];
    self.paymentConfig = [[PXPaymentConfiguration alloc] initWithSplitPaymentProcessor:paymentProcessorPlugin];
    [self addCharges];
    return self.paymentConfig;
}

-(void)addCharges {
    NSMutableArray* chargesArray = [[NSMutableArray alloc] init];
    PXPaymentTypeChargeRule* chargeAccountMoney = [[PXPaymentTypeChargeRule alloc] initWithPaymentTypeId:@"account_money" amountCharge:20 detailModal:nil];
    PXPaymentTypeChargeRule* chargeDebit = [[PXPaymentTypeChargeRule alloc] initWithPaymentTypeId:@"debit_card" amountCharge:8 detailModal:nil];
    PXPaymentTypeChargeRule* chargeZeroCreditCard = [[PXPaymentTypeChargeRule alloc] initWithPaymentTypeId:@"credit_card" message:@"Ahorro con tu banco"];

    [chargesArray addObject:chargeAccountMoney];
    [chargesArray addObject:chargeDebit];
//    [chargesArray addObject:chargeZeroCreditCard];
    [self.paymentConfig addChargeRulesWithCharges:chargesArray];
}

-(void)setCheckoutPref {
    PXItem *item = [[PXItem alloc] initWithTitle:@"title" quantity:1 unitPrice:3500.0];

    NSArray *items = [NSArray arrayWithObjects:item, nil];

    self.pref = [[PXCheckoutPreference alloc] initWithSiteId:@"MLA" payerEmail:@"sara@gmail.com" items:items];
    [self.pref setMaxInstallments:18];
    [self.pref setGatewayProcessingModes: [NSArray arrayWithObjects: @"gateway", @"aggregator", nil]];
}

-(void)setCheckoutPrefAdditionalInfo {
    // Example SP support for custom additional info.
    self.pref.additionalInfo = @"{\"px_summary\":{\"title\":\"Recarga Claro\",\"image_url\":\"https://www.rondachile.cl/wordpress/wp-content/uploads/2018/03/Logo-Claro-1.jpg\",\"subtitle\":\"Celular 1159199234\",\"purpose\":\"Tu recarga\"}}";
}

- (void)didFinishWithCheckout:(MercadoPagoCheckout * _Nonnull)checkout {
    [checkout startWithNavigationController:self.navigationController lifeCycleProtocol:self];
}

-(void)failureWithCheckout:(MercadoPagoCheckout * _Nonnull)checkout {
    NSLog(@"PXLog - LazyInit - failureWithCheckout");
}

-(void (^ _Nullable)(void))cancelCheckout {
    return ^ {
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void (^)(id<PXResult> _Nullable))finishCheckout {
    return nil;
}

-(void (^)(void))changePaymentMethodTapped {
    return nil;
}

- (void)trackEventWithScreenName:(NSString * _Nullable)screenName action:(NSString * _Null_unspecified)action result:(NSString * _Nullable)result extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track event
}

- (void)trackScreenWithScreenName:(NSString * _Nonnull)screenName extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track screen
}

@end
