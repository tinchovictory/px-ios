//
//  PaymentMethodSearchService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

internal class PaymentMethodSearchService: MercadoPagoService {

    let merchantPublicKey: String
    let payerAccessToken: String?
    let processingModes: [String]
    let branchId: String?

    init(baseURL: String, merchantPublicKey: String, payerAccessToken: String? = nil, processingModes: [String], branchId: String?) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.processingModes = processingModes
        self.branchId = branchId
        super.init(baseURL: baseURL)
    }

    internal func getPaymentMethods(_ amount: Double, customerEmail: String? = nil, customerId: String? = nil, defaultPaymenMethodId: String?, excludedPaymentTypeIds: [String], excludedPaymentMethodIds: [String], cardsWithEsc: [String]?, supportedPlugins: [String]?, site: PXSite, payer: PXPayer, language: String, differentialPricingId: String?, defaultInstallments: String?, expressEnabled: String, splitEnabled: String, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule]?, maxInstallments: String?, success: @escaping (_ paymentMethodSearch: PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        var params = MercadoPagoServices.getParamsPublicKey(merchantPublicKey)
        let roundedAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: amount)

        params.paramsAppend(key: ApiParams.AMOUNT, value: roundedAmount.stringValue)

        let newExcludedPaymentTypesIds = excludedPaymentTypeIds

        if newExcludedPaymentTypesIds.count > 0 {
            let excludedPaymentTypesParams = newExcludedPaymentTypesIds.map({ $0 }).joined(separator: ",")
            params.paramsAppend(key: ApiParams.EXCLUDED_PAYMET_TYPES, value: String(excludedPaymentTypesParams).trimSpaces())
        }

        if excludedPaymentMethodIds.count > 0 {
            let excludedPaymentMethodsParams = excludedPaymentMethodIds.joined(separator: ",")
            params.paramsAppend(key: ApiParams.EXCLUDED_PAYMENT_METHOD, value: excludedPaymentMethodsParams.trimSpaces())
        }

        if let defaultPaymenMethodId = defaultPaymenMethodId {
            params.paramsAppend(key: ApiParams.DEFAULT_PAYMENT_METHOD, value: defaultPaymenMethodId.trimSpaces())
        }

        if let customDefaultInstallments = defaultInstallments {
            params.paramsAppend(key: ApiParams.DEFAULT_INSTALLMENTS, value: customDefaultInstallments)
        }

        if let customMaxInstallments = maxInstallments {
            params.paramsAppend(key: ApiParams.MAX_INSTALLMENTS, value: customMaxInstallments)
        }

        params.paramsAppend(key: ApiParams.EMAIL, value: customerEmail)
        params.paramsAppend(key: ApiParams.CUSTOMER_ID, value: customerId)
        params.paramsAppend(key: ApiParams.SITE_ID, value: site.id)
        params.paramsAppend(key: ApiParams.API_VERSION, value: PXServicesURLConfigs.API_VERSION)
        params.paramsAppend(key: ApiParams.DIFFERENTIAL_PRICING_ID, value: differentialPricingId)

        if let cardsWithEscParams = cardsWithEsc?.map({ $0 }).joined(separator: ",") {
            params.paramsAppend(key: "cards_esc", value: cardsWithEscParams)
        }

        if let supportedPluginsParams = supportedPlugins?.map({ $0 }).joined(separator: ",") {
            params.paramsAppend(key: "support_plugins", value: supportedPluginsParams)
        }

        params.paramsAppend(key: "express_enabled", value: expressEnabled)

        params.paramsAppend(key: "split_payment_enabled", value: splitEnabled)

        let body = PXPaymentMethodSearchBody(privateKey: payer.accessToken, email: payer.email, marketplace: marketplace, productId: discountParamsConfiguration?.productId, labels: discountParamsConfiguration?.labels, charges: charges, processingModes: processingModes, branchId: branchId)
        let bodyJSON = try? body.toJSON()

        let headers = ["Accept-Language": language]

        self.request(uri: PXServicesURLConfigs.MP_SEARCH_PAYMENTS_URI, params: params, body: bodyJSON, method: HTTPMethod.post, headers: headers, cache: false, success: { (data) -> Void in
            do {
                //FIXME: remove all local mock logic when credits feature development has finished
                let fakeResponse = CreditsMockHelper.express.getFullMock()
                let newData = fakeResponse.data(using:.utf8)!

            let jsonResult = try JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments)
            if let paymentSearchDic = jsonResult as? NSDictionary {
                if paymentSearchDic["error"] != nil {
                    let apiException = try PXApiException.fromJSON(data: newData)
                    failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"], apiException: apiException))
                } else {

                    if paymentSearchDic.allKeys.count > 0 {
                        let paymentSearch = try PXPaymentMethodSearch.fromJSON(data: newData)
                        success(paymentSearch)
                    } else {
                        failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
                    }
                }
                }
            } catch {
                failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
            }

        }, failure: { (_) -> Void in
            failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }

}

//FIXME: temporary local mock helper - remove when credits feature development has finished
enum CreditsMockHelper {
    case express
    case traditional

    func getFullMock() -> String {
        switch self {
        case .express:
            return expressMock()
        case .traditional:
            return traditionalMock()
        }
    }

    private func traditionalMock() -> String {
        return """
        {
        "default_amount_configuration":"hash_no_discount",
        "discounts_configurations":{
        "hash_no_discount":{
        "is_available":true
        }
        },
        "groups":[
        {
        "id":"cards",
        "type":"group",
        "description":"Nueva tarjeta",
        "children":[
        {
        "id":"credit_card",
        "type":"payment_type",
        "description":"Nueva tarjeta de crédito",
        "comment":"No aceptamos Nevada, Gift  Card Cencosud y PM TEST JUAN.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"debit_card",
        "type":"payment_type",
        "description":"Nueva tarjeta de débito",
        "comment":"",
        "show_icon":true,
        "icon":0
        }
        ],
        "children_header":"¿Con qué tarjeta?",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"ticket",
        "type":"group",
        "description":"Pago en efectivo",
        "children":[
        {
        "id":"pagofacil",
        "type":"payment_method",
        "description":"Pago Fácil",
        "comment":"El pago se acreditará al instante.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"rapipago",
        "type":"payment_method",
        "description":"Rapipago",
        "comment":"El pago se acreditará al instante.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"bapropagos",
        "type":"payment_method",
        "description":"Provincia NET",
        "comment":"El pago se acreditará de 1 a 2 días hábiles.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"cargavirtual",
        "type":"payment_method",
        "description":"Kioscos y comercios cercanos",
        "comment":"El pago se acreditará al instante.",
        "show_icon":true,
        "icon":0
        }
        ],
        "children_header":"¿Dónde quieres pagar?",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"bank_transfer",
        "type":"group",
        "description":"Transferencia por Red Link",
        "children":[
        {
        "id":"redlink_atm",
        "type":"payment_method",
        "description":"Cajero automático",
        "comment":"El pago se acreditará de 1 a 2 días hábiles.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"redlink_bank_transfer",
        "type":"payment_method",
        "description":"Home Banking",
        "comment":"El pago se acreditará de 1 a 2 días hábiles.",
        "show_icon":true,
        "icon":0
        }
        ],
        "children_header":"¿Cómo quieres pagar?",
        "show_icon":true,
        "icon":0
        }
        ],
        "custom_options":[
        {
        "id":"consumer_credits",
        "payment_method_id":"consumer_credits",
        "description":"Mercado Crédito",
        "payment_type_id":"digital_currency",
        "comment":"Hasta 12 cuotas",
        "accreditation_time":0,
        "status":"active",
        "default_amount_configuration":"hash_no_discount",
        "amount_configurations":{
        "hash_no_discount":{
        "payer_costs":[
        {
        "installments":1,
        "labels":[
        "CFT_0,00%|TEA_0,00%"
        ],
        "installment_rate":0,
        "total_amount":100,
        "installment_amount":100,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"1 cuota de $ 100,00 ($ 100,00)"
        },
        {
        "installments":12,
        "labels":[
        "recommended_installment",
        "CFT_219,13%|TEA_168,35%"
        ],
        "installment_rate":77.4,
        "total_amount":177.4,
        "installment_amount":14.78,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"12 cuotas de $ 14,78 ($ 177,40)"
        }
        ],
        "selected_payer_cost_index":0
        }
        }
        },
        {
        "description":"Terminada en 7522",
        "id":"306978637",
        "payment_type_id":"credit_card",
        "payment_method_id":"amex",
        "default_amount_configuration":"hash_no_discount",
        "amount_configurations":{
        "hash_no_discount":{
        "payer_costs":[
        {
        "installments":1,
        "labels":[
        "CFT_0,00%|TEA_0,00%"
        ],
        "installment_rate":0,
        "total_amount":100,
        "installment_amount":100,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"1 cuota de $ 100,00 ($ 100,00)"
        },
        {
        "installments":3,
        "labels":[
        "CFT_199,44%|TEA_150,35%"
        ],
        "installment_rate":19.72,
        "total_amount":119.72,
        "installment_amount":39.91,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"3 cuotas de $ 39,91 ($ 119,72)"
        },
        {
        "installments":6,
        "labels":[
        "CFT_187,01%|TEA_142,79%",
        "recommended_interest_installment_with_some_banks"
        ],
        "installment_rate":34.49,
        "total_amount":134.49,
        "installment_amount":22.42,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"6 cuotas de $ 22,42 ($ 134,49)"
        },
        {
        "installments":9,
        "labels":[
        "CFT_217,13%|TEA_165,77%"
        ],
        "installment_rate":56.9,
        "total_amount":156.89,
        "installment_amount":17.43,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"9 cuotas de $ 17,43 ($ 156,89)"
        },
        {
        "installments":12,
        "labels":[
        "recommended_installment",
        "CFT_219,13%|TEA_168,35%"
        ],
        "installment_rate":77.4,
        "total_amount":177.4,
        "installment_amount":14.78,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"12 cuotas de $ 14,78 ($ 177,40)"
        }
        ],
        "selected_payer_cost_index":0
        }
        },
        "issuer":{
        "id":"2",
        "name":"American Express"
        },
        "first_six_digits":"371180",
        "last_four_digits":"7522"
        }
        ],
        "payment_methods":[
        {
        "id":"mercadopago_cc",
        "name":"Mercado Pago + Banco Patagonia",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/mercadopago_cc.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((515073)|(515070)|(532384))",
        "pattern":"^((515073)|(515070)|(532384))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        },
        {
        "bin":{
        "installments_pattern":"^(532383)",
        "pattern":"^(532383)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"nativa",
        "name":"Nativa Mastercard",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/nativa.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((520053)|(546553)|(554472)|(531847)|(527601))",
        "pattern":"^((520053)|(546553)|(554472)|(531847)|(527601))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_name",
        "cardholder_identification_type"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cabal",
        "name":"Cabal",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cabal.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^((604201)|(604209))",
        "installments_pattern":"^((627170)|(589657)|(603522)|(604((20[1-9])|(2[1-9][0-9])|(3[0-9]{2})|(400))))",
        "pattern":"^((627170)|(589657)|(603522)|(604((20[1-9])|(2[1-9][0-9])|(3[0-9]{2})|(400))))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cencosud",
        "name":"Cencosud",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cencosud.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(603493)",
        "pattern":"^(603493)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"master",
        "name":"Mastercard",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/master.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^(514256|514586|526461|511309|514285|501059|557909|501082|589633|501060|501051|501016|589657|553839|525855|553777|553771|551792|528733|549180|528745|517562|511849|557648|546367|501070|601782|508143|501085|501074|501073|501071|501068|501066|589671|589633|588729|501089|501083|501082|501081|501080|501075|501067|501062|501061|501060|501058|501057|501056|501055|501054|501053|501051|501049|501047|501045|501043|501041|501040|501039|501038|501029|501028|501027|501026|501025|501024|501023|501021|501020|501018|501016|501015|589657|589562|501105|557039|542702|544764|550073|528824|522135|522137|562397|566694|566783|568382|569322|504363)",
        "installments_pattern":"^(?!554730)",
        "pattern":"^(5|(2(221|222|223|224|225|226|227|228|229|23|24|25|26|27|28|29|3|4|5|6|70|71|720)))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number",
        "issuer_id"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"debcabal",
        "name":"Cabal Débito",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/debcabal.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":1440,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(604201)",
        "pattern":"^(604201)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":10000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cordial",
        "name":"Tarjeta Walmart",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cordial.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(522135|522137)",
        "pattern":"^(522135|522137)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cordobesa",
        "name":"Cordobesa",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cordobesa.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((542702)|(544764)|(550073))",
        "pattern":"^((542702)|(544764)|(550073)|(528824))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cmr",
        "name":"CMR",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cmr.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(557039)",
        "pattern":"^(557039)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"maestro",
        "name":"Maestro",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/maestro.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":1440,
        "settings":[
        {
        "bin":{
        "pattern":"^(501051|501059|557909|501066|588729|501075|501062|501060|501057|501056|501055|501053|501043|501041|501038|501028|501023|501021|501020|501018|501016)"
        },
        "card_number":{
        "length":18,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        },
        {
        "bin":{
        "pattern":"^(601782|508143|501081|501080)"
        },
        "card_number":{
        "length":19,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"debmaster",
        "name":"Mastercard Débito",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/debmaster.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":1440,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(526461|514365|514256|514586|525855|511309|514285|553839|553777|553771|551792|528733|549180|528745|517562|511849|557648|546367)",
        "pattern":"^(526461|514365|514256|514586|525855|511309|514285|553839|553777|553771|551792|528733|549180|528745|517562|511849|557648|546367)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name",
        "issuer_id"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"naranja",
        "name":"Naranja",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/naranja.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(589562)",
        "pattern":"^(589562)"
        },
        "card_number":{
        "length":16,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"amex",
        "name":"American Express",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/amex.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((34)|(37))",
        "pattern":"^((34)|(37))"
        },
        "card_number":{
        "length":15,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"front",
        "length":4
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"tarshop",
        "name":"Tarjeta Shopping",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/tarshop.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(27995)",
        "pattern":"^(27995)"
        },
        "card_number":{
        "length":13,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":0
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_number",
        "cardholder_identification_type"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"diners",
        "name":"Diners",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/diners.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^((3646)|(3648))",
        "installments_pattern":"^((360935)|(360936))",
        "pattern":"^((30)|(36)|(38))"
        },
        "card_number":{
        "length":14,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"argencard",
        "name":"Argencard",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/argencard.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^((589562)|(527571)|(527572))",
        "installments_pattern":"^(501105)",
        "pattern":"^(501105)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"debvisa",
        "name":"Visa Débito",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/debvisa.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^(491580)",
        "installments_pattern":"^(400276|400448|400615|400930|402789|402914|404022|404625|405069|405511|405515|405516|405517|405755|405896|405897|406165|406190|406191|406192|406193|406194|406195|406196|406290|406291|406375|406652|406998|406999|408134|408515|410082|410083|410121|410122|410123|410853|411197|411199|411849|412944|413180|416679|416861|417309|417856|417857|421518|421528|421541|421738|423001|423018|423077|423090|423465|423613|423613|423623|424968|424969|426618|427156|427157|428062|428063|428064|429751|429752|431070|431071|434531|434532|434533|434534|434535|434536|434537|434538|434539|434540|434541|434542|434543|434549|434550|434586|434795|437996|437999|438050|438051|438844|439818|441046|442371|442548|443264|444047|444060|444267|444268|444493|446343|446344|446345|446346|446347|448712|450412|450799|450811|451377|451701|451751|451756|451757|451758|451761|451763|451764|451765|451766|451767|451768|451769|451770|451772|451773|452132|452133|453770|455890|457308|457596|457664|457665|459300|462815|463465|464855|468508|469283|469874|472041|472042|473227|473365|473710|473711|473712|473713|473714|473715|473716|473717|473718|473719|473720|473721|473722|473725|474531|476520|477051|477053|477169|478017|478527|478601|480459|480460|480724|480860|481397|481501|481502|481550|483002|483020|483188|485089|485947|486547|486587|486621|486665|487221|488241|489412|489634|492499|492528|492596|492597|492598|499859)",
        "pattern":"^(400276|400448|400615|400930|402789|402914|404022|404625|405069|405511|405515|405516|405517|405755|405896|405897|406165|406190|406191|406192|406193|406194|406195|406196|406290|406291|406375|406652|406998|406999|408134|408515|410082|410083|410121|410122|410123|410853|411197|411199|411849|412944|413180|416679|416861|417309|417856|417857|421518|421528|421541|421738|423001|423018|423077|423090|423465|423613|423613|423623|424968|424969|426618|427156|427157|428062|428063|428064|429751|429752|431070|431071|434531|434532|434533|434534|434535|434536|434537|434538|434539|434540|434541|434542|434543|434549|434550|434586|434795|437996|437999|438050|438051|438844|439818|441046|442371|442548|443264|444047|444060|444267|444268|444493|446343|446344|446345|446346|446347|448712|450412|450799|450811|451377|451701|451751|451756|451757|451758|451761|451763|451764|451765|451766|451767|451768|451769|451770|451772|451773|452132|452133|453770|455890|457308|457596|457664|457665|459300|462815|463465|464855|468508|469283|469874|472041|472042|473227|473365|473710|473711|473712|473713|473714|473715|473716|473717|473718|473719|473720|473721|473722|473725|474531|476520|477051|477053|477169|478017|478527|478601|480459|480460|480724|480860|481397|481501|481502|481550|483002|483020|483188|485089|485947|486547|486587|486621|486665|487221|488241|489412|489634|492499|492528|492596|492597|492598|499859)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"visa",
        "name":"Visa",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/visa.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^(476520|473713|473713|473227|444493|410122|405517|402789|417856|448712|453770|434541|411199|423465|434540|434542|434538|423018|488241|489634|434537|434539|434536|427156|427157|434535|434534|434533|423077|434532|434586|423001|434531|411197|443264|400276|400615|402914|404625|405069|434543|416679|405515|405516|405755|405896|405897|406290|406291|406375|406652|406998|406999|408515|410082|410083|410121|410123|410853|411849|417309|421738|423623|428062|428063|428064|434795|437996|439818|442371|442548|444060|446343|446344|446347|450412|450799|451377|451701|451751|451756|451757|451758|451761|451763|451764|451765|451766|451767|451768|451769|451770|451772|451773|457596|457665|462815|463465|468508|473710|473711|473712|473714|473715|473716|473717|473718|473719|473720|473721|473722|473725|477051|477053|481397|481501|481502|481550|483002|483020|483188|489412|492528|499859|446344|446345|446346|400448)",
        "installments_pattern":"^4",
        "pattern":"^4"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"pagofacil",
        "name":"Pago Fácil",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/pagofacil.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":0,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":10,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"rapipago",
        "name":"Rapipago",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/rapipago.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":0,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"redlink",
        "name":"Red Link",
        "payment_type_id":"atm",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/redlink.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":2880,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"bapropagos",
        "name":"Provincia NET",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/bapropagos.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":2880,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"consumer_credits",
        "name":"Mercado Crédito",
        "payment_type_id":"digital_currency",
        "accreditation_time":0,
        "status":"active",
        "secure_thumbnail":"…",
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "processing_modes":[

        ],
        "display_info":{
        "terms_and_conditions":{
        "text":"Al pagar, aceptás las condiciones generales y particulares de este préstamo.",
        "linkable_phrases":[
        {
        "phrase":"generales",
        "link":"https://www.caatlanta.com.ar/"
        },
        {
        "phrase":"particulares",
        "link":"https://www.caatlanta.com.ar/"
        }
        ]
        },
        "result_info":{
        "title":"Pagás la primera cuota el 5 de diciembre.",
        "subtitle":"Hacelo en efectivo en Rapipago o Pago Fácil, con débito, o con el dinero en tu cuenta de Mercado Pago.",
        "main_action":{
        "label":"Descargar comprobante",
        "link":"www.mercadopago.com/comprobantes"
        },
        "link_action":{
        "label":"Volver al inicio"
        }
        }
        }
        },
        {
        "id":"cargavirtual",
        "name":"Kioscos y comercios cercanos",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cargavirtual.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":0,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":5000,
        "processing_modes":[
        "aggregator"
        ]
        }
        ]
        }
        """
    }

    private func expressMock() -> String {
        return """
        {
        "express":[
        {
        "payment_method_id":"consumer_credits",
        "payment_type_id":"digital_currency",
        "customer_credits":{
        "payment_method_icon":"mercado_creditos",
        "payment_method_side_text":"Pagá en hasta 12 cuotas sin usar tarjeta",
        "bottom_text":{
        "text":"Al pagar, aceptás las condiciones generales y particulares de este préstamo.",
        "linkable_phrases":[
        {
        "phrase":"generales",
        "link":"https://www.caatlanta.com.ar/"
        },
        {
        "phrase":"particulares",
        "link":"https://www.caatlanta.com.ar/"
        }
        ]
        }
        }
        },
        {
        "payment_method_id":"amex",
        "payment_type_id":"credit_card",
        "card":{
        "id":"306978637",
        "display_info":{
        "expiration":"11/22",
        "last_four_digits":"7522",
        "first_six_digits":"371180",
        "issuer_id":"2",
        "cardholder_name":"FEDE",
        "security_code":{
        "length":4,
        "card_location":"front"
        },
        "card_pattern":[
        4,
        6,
        5
        ],
        "color":"#87AB9E",
        "font_color":"#FFFFFF",
        "payment_method_image":"buflo_payment_card_amex",
        "font_type":"dark"
        }
        }
        }
        ],
        "default_amount_configuration":"hash_no_discount",
        "discounts_configurations":{
        "hash_no_discount":{
        "is_available":true
        }
        },
        "groups":[
        {
        "id":"cards",
        "type":"group",
        "description":"Nueva tarjeta",
        "children":[
        {
        "id":"credit_card",
        "type":"payment_type",
        "description":"Nueva tarjeta de crédito",
        "comment":"No aceptamos Nevada, Gift  Card Cencosud y PM TEST JUAN.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"debit_card",
        "type":"payment_type",
        "description":"Nueva tarjeta de débito",
        "comment":"",
        "show_icon":true,
        "icon":0
        }
        ],
        "children_header":"¿Con qué tarjeta?",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"ticket",
        "type":"group",
        "description":"Pago en efectivo",
        "children":[
        {
        "id":"pagofacil",
        "type":"payment_method",
        "description":"Pago Fácil",
        "comment":"El pago se acreditará al instante.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"rapipago",
        "type":"payment_method",
        "description":"Rapipago",
        "comment":"El pago se acreditará al instante.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"bapropagos",
        "type":"payment_method",
        "description":"Provincia NET",
        "comment":"El pago se acreditará de 1 a 2 días hábiles.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"cargavirtual",
        "type":"payment_method",
        "description":"Kioscos y comercios cercanos",
        "comment":"El pago se acreditará al instante.",
        "show_icon":true,
        "icon":0
        }
        ],
        "children_header":"¿Dónde quieres pagar?",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"bank_transfer",
        "type":"group",
        "description":"Transferencia por Red Link",
        "children":[
        {
        "id":"redlink_atm",
        "type":"payment_method",
        "description":"Cajero automático",
        "comment":"El pago se acreditará de 1 a 2 días hábiles.",
        "show_icon":true,
        "icon":0
        },
        {
        "id":"redlink_bank_transfer",
        "type":"payment_method",
        "description":"Home Banking",
        "comment":"El pago se acreditará de 1 a 2 días hábiles.",
        "show_icon":true,
        "icon":0
        }
        ],
        "children_header":"¿Cómo quieres pagar?",
        "show_icon":true,
        "icon":0
        }
        ],
        "custom_options":[
        {
        "id":"consumer_credits",
        "payment_method_id":"consumer_credits",
        "description":"Mercado Crédito",
        "payment_type_id":"digital_currency",
        "comment":"Hasta 12 cuotas",
        "accreditation_time":0,
        "status":"active",
        "default_amount_configuration":"hash_no_discount",
        "amount_configurations":{
        "hash_no_discount":{
        "payer_costs":[
        {
        "installments":1,
        "labels":[
        "CFT_0,00%|TEA_0,00%"
        ],
        "installment_rate":0,
        "total_amount":100,
        "installment_amount":100,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"1 cuota de $ 100,00 ($ 100,00)"
        },
        {
        "installments":12,
        "labels":[
        "recommended_installment",
        "CFT_219,13%|TEA_168,35%"
        ],
        "installment_rate":77.4,
        "total_amount":177.4,
        "installment_amount":14.78,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"12 cuotas de $ 14,78 ($ 177,40)"
        }
        ],
        "selected_payer_cost_index":0
        }
        }
        },
        {
        "description":"Terminada en 7522",
        "id":"306978637",
        "payment_type_id":"credit_card",
        "payment_method_id":"amex",
        "default_amount_configuration":"hash_no_discount",
        "amount_configurations":{
        "hash_no_discount":{
        "payer_costs":[
        {
        "installments":1,
        "labels":[
        "CFT_0,00%|TEA_0,00%"
        ],
        "installment_rate":0,
        "total_amount":100,
        "installment_amount":100,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"1 cuota de $ 100,00 ($ 100,00)"
        },
        {
        "installments":3,
        "labels":[
        "CFT_199,44%|TEA_150,35%"
        ],
        "installment_rate":19.72,
        "total_amount":119.72,
        "installment_amount":39.91,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"3 cuotas de $ 39,91 ($ 119,72)"
        },
        {
        "installments":6,
        "labels":[
        "CFT_187,01%|TEA_142,79%",
        "recommended_interest_installment_with_some_banks"
        ],
        "installment_rate":34.49,
        "total_amount":134.49,
        "installment_amount":22.42,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"6 cuotas de $ 22,42 ($ 134,49)"
        },
        {
        "installments":9,
        "labels":[
        "CFT_217,13%|TEA_165,77%"
        ],
        "installment_rate":56.9,
        "total_amount":156.89,
        "installment_amount":17.43,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"9 cuotas de $ 17,43 ($ 156,89)"
        },
        {
        "installments":12,
        "labels":[
        "recommended_installment",
        "CFT_219,13%|TEA_168,35%"
        ],
        "installment_rate":77.4,
        "total_amount":177.4,
        "installment_amount":14.78,
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "recommended_message":"12 cuotas de $ 14,78 ($ 177,40)"
        }
        ],
        "selected_payer_cost_index":0
        }
        },
        "issuer":{
        "id":"2",
        "name":"American Express"
        },
        "first_six_digits":"371180",
        "last_four_digits":"7522"
        }
        ],
        "payment_methods":[
        {
        "id":"mercadopago_cc",
        "name":"Mercado Pago + Banco Patagonia",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/mercadopago_cc.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((515073)|(515070)|(532384))",
        "pattern":"^((515073)|(515070)|(532384))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        },
        {
        "bin":{
        "installments_pattern":"^(532383)",
        "pattern":"^(532383)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"nativa",
        "name":"Nativa Mastercard",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/nativa.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((520053)|(546553)|(554472)|(531847)|(527601))",
        "pattern":"^((520053)|(546553)|(554472)|(531847)|(527601))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_name",
        "cardholder_identification_type"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cabal",
        "name":"Cabal",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cabal.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^((604201)|(604209))",
        "installments_pattern":"^((627170)|(589657)|(603522)|(604((20[1-9])|(2[1-9][0-9])|(3[0-9]{2})|(400))))",
        "pattern":"^((627170)|(589657)|(603522)|(604((20[1-9])|(2[1-9][0-9])|(3[0-9]{2})|(400))))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cencosud",
        "name":"Cencosud",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cencosud.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(603493)",
        "pattern":"^(603493)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"master",
        "name":"Mastercard",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/master.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^(514256|514586|526461|511309|514285|501059|557909|501082|589633|501060|501051|501016|589657|553839|525855|553777|553771|551792|528733|549180|528745|517562|511849|557648|546367|501070|601782|508143|501085|501074|501073|501071|501068|501066|589671|589633|588729|501089|501083|501082|501081|501080|501075|501067|501062|501061|501060|501058|501057|501056|501055|501054|501053|501051|501049|501047|501045|501043|501041|501040|501039|501038|501029|501028|501027|501026|501025|501024|501023|501021|501020|501018|501016|501015|589657|589562|501105|557039|542702|544764|550073|528824|522135|522137|562397|566694|566783|568382|569322|504363)",
        "installments_pattern":"^(?!554730)",
        "pattern":"^(5|(2(221|222|223|224|225|226|227|228|229|23|24|25|26|27|28|29|3|4|5|6|70|71|720)))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number",
        "issuer_id"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"debcabal",
        "name":"Cabal Débito",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/debcabal.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":1440,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(604201)",
        "pattern":"^(604201)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":10000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cordial",
        "name":"Tarjeta Walmart",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cordial.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(522135|522137)",
        "pattern":"^(522135|522137)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cordobesa",
        "name":"Cordobesa",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cordobesa.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((542702)|(544764)|(550073))",
        "pattern":"^((542702)|(544764)|(550073)|(528824))"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"cmr",
        "name":"CMR",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cmr.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(557039)",
        "pattern":"^(557039)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"maestro",
        "name":"Maestro",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/maestro.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":1440,
        "settings":[
        {
        "bin":{
        "pattern":"^(501051|501059|557909|501066|588729|501075|501062|501060|501057|501056|501055|501053|501043|501041|501038|501028|501023|501021|501020|501018|501016)"
        },
        "card_number":{
        "length":18,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        },
        {
        "bin":{
        "pattern":"^(601782|508143|501081|501080)"
        },
        "card_number":{
        "length":19,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"debmaster",
        "name":"Mastercard Débito",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/debmaster.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":1440,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(526461|514365|514256|514586|525855|511309|514285|553839|553777|553771|551792|528733|549180|528745|517562|511849|557648|546367)",
        "pattern":"^(526461|514365|514256|514586|525855|511309|514285|553839|553777|553771|551792|528733|549180|528745|517562|511849|557648|546367)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name",
        "issuer_id"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"naranja",
        "name":"Naranja",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/naranja.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(589562)",
        "pattern":"^(589562)"
        },
        "card_number":{
        "length":16,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"amex",
        "name":"American Express",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/amex.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^((34)|(37))",
        "pattern":"^((34)|(37))"
        },
        "card_number":{
        "length":15,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"front",
        "length":4
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_number",
        "cardholder_identification_type",
        "cardholder_name"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"tarshop",
        "name":"Tarjeta Shopping",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/tarshop.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "installments_pattern":"^(27995)",
        "pattern":"^(27995)"
        },
        "card_number":{
        "length":13,
        "validation":"none"
        },
        "security_code":{
        "card_location":"back",
        "length":0
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_number",
        "cardholder_identification_type"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"diners",
        "name":"Diners",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/diners.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^((3646)|(3648))",
        "installments_pattern":"^((360935)|(360936))",
        "pattern":"^((30)|(36)|(38))"
        },
        "card_number":{
        "length":14,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"argencard",
        "name":"Argencard",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/argencard.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^((589562)|(527571)|(527572))",
        "installments_pattern":"^(501105)",
        "pattern":"^(501105)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_identification_type",
        "cardholder_name",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"debvisa",
        "name":"Visa Débito",
        "payment_type_id":"debit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/debvisa.gif",
        "deferred_capture":"unsupported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^(491580)",
        "installments_pattern":"^(400276|400448|400615|400930|402789|402914|404022|404625|405069|405511|405515|405516|405517|405755|405896|405897|406165|406190|406191|406192|406193|406194|406195|406196|406290|406291|406375|406652|406998|406999|408134|408515|410082|410083|410121|410122|410123|410853|411197|411199|411849|412944|413180|416679|416861|417309|417856|417857|421518|421528|421541|421738|423001|423018|423077|423090|423465|423613|423613|423623|424968|424969|426618|427156|427157|428062|428063|428064|429751|429752|431070|431071|434531|434532|434533|434534|434535|434536|434537|434538|434539|434540|434541|434542|434543|434549|434550|434586|434795|437996|437999|438050|438051|438844|439818|441046|442371|442548|443264|444047|444060|444267|444268|444493|446343|446344|446345|446346|446347|448712|450412|450799|450811|451377|451701|451751|451756|451757|451758|451761|451763|451764|451765|451766|451767|451768|451769|451770|451772|451773|452132|452133|453770|455890|457308|457596|457664|457665|459300|462815|463465|464855|468508|469283|469874|472041|472042|473227|473365|473710|473711|473712|473713|473714|473715|473716|473717|473718|473719|473720|473721|473722|473725|474531|476520|477051|477053|477169|478017|478527|478601|480459|480460|480724|480860|481397|481501|481502|481550|483002|483020|483188|485089|485947|486547|486587|486621|486665|487221|488241|489412|489634|492499|492528|492596|492597|492598|499859)",
        "pattern":"^(400276|400448|400615|400930|402789|402914|404022|404625|405069|405511|405515|405516|405517|405755|405896|405897|406165|406190|406191|406192|406193|406194|406195|406196|406290|406291|406375|406652|406998|406999|408134|408515|410082|410083|410121|410122|410123|410853|411197|411199|411849|412944|413180|416679|416861|417309|417856|417857|421518|421528|421541|421738|423001|423018|423077|423090|423465|423613|423613|423623|424968|424969|426618|427156|427157|428062|428063|428064|429751|429752|431070|431071|434531|434532|434533|434534|434535|434536|434537|434538|434539|434540|434541|434542|434543|434549|434550|434586|434795|437996|437999|438050|438051|438844|439818|441046|442371|442548|443264|444047|444060|444267|444268|444493|446343|446344|446345|446346|446347|448712|450412|450799|450811|451377|451701|451751|451756|451757|451758|451761|451763|451764|451765|451766|451767|451768|451769|451770|451772|451773|452132|452133|453770|455890|457308|457596|457664|457665|459300|462815|463465|464855|468508|469283|469874|472041|472042|473227|473365|473710|473711|473712|473713|473714|473715|473716|473717|473718|473719|473720|473721|473722|473725|474531|476520|477051|477053|477169|478017|478527|478601|480459|480460|480724|480860|481397|481501|481502|481550|483002|483020|483188|485089|485947|486547|486587|486621|486665|487221|488241|489412|489634|492499|492528|492596|492597|492598|499859)"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"visa",
        "name":"Visa",
        "payment_type_id":"credit_card",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/visa.gif",
        "deferred_capture":"supported",
        "accreditation_time":2880,
        "settings":[
        {
        "bin":{
        "exclusion_pattern":"^(476520|473713|473713|473227|444493|410122|405517|402789|417856|448712|453770|434541|411199|423465|434540|434542|434538|423018|488241|489634|434537|434539|434536|427156|427157|434535|434534|434533|423077|434532|434586|423001|434531|411197|443264|400276|400615|402914|404625|405069|434543|416679|405515|405516|405755|405896|405897|406290|406291|406375|406652|406998|406999|408515|410082|410083|410121|410123|410853|411849|417309|421738|423623|428062|428063|428064|434795|437996|439818|442371|442548|444060|446343|446344|446347|450412|450799|451377|451701|451751|451756|451757|451758|451761|451763|451764|451765|451766|451767|451768|451769|451770|451772|451773|457596|457665|462815|463465|468508|473710|473711|473712|473714|473715|473716|473717|473718|473719|473720|473721|473722|473725|477051|477053|481397|481501|481502|481550|483002|483020|483188|489412|492528|499859|446344|446345|446346|400448)",
        "installments_pattern":"^4",
        "pattern":"^4"
        },
        "card_number":{
        "length":16,
        "validation":"standard"
        },
        "security_code":{
        "card_location":"back",
        "length":3
        }
        }
        ],
        "additional_info_needed":[
        "cardholder_name",
        "cardholder_identification_type",
        "cardholder_identification_number"
        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "max_allowed_amount":250000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"pagofacil",
        "name":"Pago Fácil",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/pagofacil.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":0,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":10,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"rapipago",
        "name":"Rapipago",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/rapipago.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":0,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"redlink",
        "name":"Red Link",
        "payment_type_id":"atm",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/redlink.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":2880,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"bapropagos",
        "name":"Provincia NET",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/bapropagos.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":2880,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":60000,
        "processing_modes":[
        "aggregator"
        ]
        },
        {
        "id":"consumer_credits",
        "name":"Mercado Crédito",
        "payment_type_id":"digital_currency",
        "accreditation_time":0,
        "status":"active",
        "secure_thumbnail":"…",
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":1,
        "processing_modes":[

        ],
        "display_info":{
        "terms_and_conditions":{
        "text":"Al pagar, aceptás los términos generales y las condiciones particulares de este préstamo.",
        "linkable_phrases":[
        {
        "phrase":"términos generales",
        "link":"https://www.caatlanta.com.ar/"
        },
        {
        "phrase":"condiciones particulares",
        "link":"https://www.caatlanta.com.ar/"
        }
        ]
        },
        "result_info":{
        "title":"Pagás la primera cuota el 5 de diciembre.",
        "subtitle":"Hacelo en efectivo en Rapipago o Pago Fácil, con débito, o con el dinero en tu cuenta de Mercado Pago.",
        "main_action":{
        "label":"Descargar comprobante",
        "link":"www.mercadopago.com/comprobantes"
        },
        "link_action":{
        "label":"Volver al inicio"
        }
        }
        }
        },
        {
        "id":"cargavirtual",
        "name":"Kioscos y comercios cercanos",
        "payment_type_id":"ticket",
        "status":"active",
        "secure_thumbnail":"https://www.mercadopago.com/org-img/MP3/API/logos/cargavirtual.gif",
        "deferred_capture":"does_not_apply",
        "accreditation_time":0,
        "settings":[

        ],
        "additional_info_needed":[

        ],
        "financial_institutions":[

        ],
        "min_allowed_amount":0.01,
        "max_allowed_amount":5000,
        "processing_modes":[
        "aggregator"
        ]
        }
        ]
        }
"""
    }

}
