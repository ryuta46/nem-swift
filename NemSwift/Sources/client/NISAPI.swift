//
//  NISAPI.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation
import APIKit

final class NISAPI {
    private init() {}

    static var defaultBaseURL: URL = URL(string: "http://localhost:7890")!

    class NISGetRequest<T: Decodable>: NISRequest {
        typealias Response = T
        let baseURL: URL
        let method: HTTPMethod = .get
        let path: String
        let parameters: Any?

        fileprivate init(baseURL: URL, path: String, parameters: Dictionary<String, Any?> = [:]) {
            self.baseURL = baseURL
            self.path = path
            self.parameters = parameters.filter({ (key, value) -> Bool in value != nil })
        }
    }

    class NISPostRequest<T: Decodable>: NISRequest {
        typealias Response = T
        let baseURL: URL
        let method: HTTPMethod = .post
        let path: String
        let parameters: Any?

        fileprivate init(baseURL: URL, path: String, parameters: Dictionary<String, Any?> = [:]) {
            self.baseURL = baseURL
            self.path = path
            self.parameters = parameters.filter({ (key, value) -> Bool in value != nil })
        }
    }

    // 3.1.2 Requesting the account data
    class AccountGet: NISGetRequest<AccountMetaDataPair> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/get", parameters: ["address": address])
        }
    }

    // 3.1.2 Requesting the account data from public key
    class AccountGetFromPublicKey: NISGetRequest<AccountMetaDataPair> {
        init(baseURL: URL = NISAPI.defaultBaseURL, publicKey: String) {
            super.init(baseURL: baseURL, path: "/account/get/from-public-key", parameters: ["publicKey": publicKey])
        }
    }
    
    // 3.1.3 Requesting the original account data for a delegate account
    class AccountGetForwarded: NISGetRequest<AccountMetaDataPair> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/get/forwarded", parameters: ["address": address])
        }
    }
    
    // 3.1.3 Requesting the original account data for a delegate account from public key
    class AccountGetForwardedFromPublicKey: NISGetRequest<AccountMetaDataPair> {
        init(baseURL: URL = NISAPI.defaultBaseURL, publicKey: String) {
            super.init(baseURL: baseURL, path: "/account/get/forwarded/from-public-key", parameters: ["publicKey": publicKey])
        }
    }
    
    // 3.1.4 Requesting the account status
    class AccountStatus: NISGetRequest<AccountMetaData> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/status", parameters: ["address": address])
        }
    }
    
    // 3.1.5 Requesting transaction data for an account
    class AccountTransfersIncoming: NISGetRequest<TransactionMetaDataPairs> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String, hash: String? = nil, id: String? = nil) {
            super.init(baseURL: baseURL, path: "/account/transfers/incoming",
                       parameters: ["address": address, "hash": hash, "id": id])
        }
    }
    
    class AccountTransfersOutgoing: NISGetRequest<TransactionMetaDataPairs> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String, hash: String? = nil, id: String? = nil) {
            super.init(baseURL: baseURL, path: "/account/transfers/outgoing",
                       parameters: ["address": address, "hash": hash, "id": id])
        }
    }
    
    class AccountTransfersAll: NISGetRequest<TransactionMetaDataPairs> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String, hash: String? = nil, id: String? = nil) {
            super.init(baseURL: baseURL, path: "/account/transfers/all",
                       parameters: ["address": address, "hash": hash, "id": id])
        }
    }
    
    class AccountUnconfirmedTransactions: NISGetRequest<UnconfirmedTransactionMetaDataPairs> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/unconfirmedTransactions", parameters: ["address": address])
        }
    }
    
    // 3.1.7 Requesting harvest info data for an account
    class AccountHarvests: NISGetRequest<Harvests> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String, hash: String? = nil) {
            super.init(baseURL: baseURL, path: "/account/harvests",
                       parameters: ["address": address, "hash": hash])
        }
    }
    
    // 3.1.8 Retrieving account importances for accounts
    class AccountImportances: NISGetRequest<Importances> {
        init(baseURL: URL = NISAPI.defaultBaseURL) {
            super.init(baseURL: baseURL, path: "/account/importances")
        }
    }
    
    // 3.1.9 Retrieving namespaces that an account owns
    class AccountNamespacePage: NISGetRequest<Namespaces> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String, parent: String? = nil, id: Int? = nil, pageSize: Int? = nil) {
            super.init(baseURL: baseURL, path: "/account/namespace/page",
                       parameters: ["address": address, "parent": parent, "id": id, "pageSize": pageSize])
        }
    }
    
    class NamespaceMosaicDefintionPage: NISGetRequest<MosaicDefinitionMetaDataPairs> {
        init(baseURL: URL = NISAPI.defaultBaseURL, namespace: String, id: Int? = nil, pageSize: Int? = nil) {
            super.init(baseURL: baseURL, path: "/namespace/mosaic/definition/page",
                       parameters: ["namespace": namespace, "id": id, "pagesize": pageSize])
        }
    }
    
    // Retrieving mosaics that an account owns
    class AccountMosaicOwned: NISGetRequest<Mosaics> {
        init(baseURL: URL = NISAPI.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/mosaic/owned", parameters: ["address": address])
        }
    }
    
    // 7.9.2 Sending the data to NIS
    class TransactionAnnounce: NISPostRequest<NemAnnounceResult> {
        init(baseURL: URL = NISAPI.defaultBaseURL, data: String, signature: String) {
            super.init(baseURL: baseURL, path: "/transaction/announce", parameters: ["data": data, "signature": signature])
        }
    }
}
