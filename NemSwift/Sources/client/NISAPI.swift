//
//  NISAPI.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation
import APIKit

public final class NISAPI {
    private init() {}

    public class NISGetRequest<T: Decodable>: NISRequest {
        public typealias Response = T
        public let baseURL: URL
        public let method: HTTPMethod = .get
        public let path: String
        public let parameters: Any?

        public var dataParser: DataParser {
            return DecodableDataParser()
        }

        fileprivate init(baseURL: URL, path: String, parameters: Dictionary<String, Any?> = [:]) {
            self.baseURL = baseURL
            self.path = path
            let filteredParameters = parameters
                .filter({ (key, value) -> Bool in value != nil }) // remove nil parameters
                .map({ (key, value) in (key, value!) }) // unwrap
            self.parameters = Dictionary<String, Any>(uniqueKeysWithValues: filteredParameters)
        }
    }

    public class NISPostRequest<T: Decodable>: NISRequest {
        public typealias Response = T
        public let baseURL: URL
        public let method: HTTPMethod = .post
        public let path: String
        public let parameters: Any?

        public var dataParser: DataParser {
            return DecodableDataParser()
        }

        fileprivate init(baseURL: URL, path: String, parameters: Dictionary<String, Any?> = [:]) {
            self.baseURL = baseURL
            self.path = path
            let filteredParameters = parameters
                .filter({ (key, value) -> Bool in value != nil }) // remove nil parameters
                .map({ (key, value) in (key, value!) }) // unwrap
            self.parameters = Dictionary<String, Any>(uniqueKeysWithValues: filteredParameters)
        }
    }


    // 3.1.2 Requesting the account data
    public class AccountGet: NISGetRequest<AccountMetaDataPair> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/get", parameters: ["address": address])
        }
    }

    // 3.1.2 Requesting the account data from public key
    public class AccountGetFromPublicKey: NISGetRequest<AccountMetaDataPair> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, publicKey: String) {
            super.init(baseURL: baseURL, path: "/account/get/from-public-key", parameters: ["publicKey": publicKey])
        }
    }
    
    // 3.1.3 Requesting the original account data for a delegate account
    public class AccountGetForwarded: NISGetRequest<AccountMetaDataPair> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/get/forwarded", parameters: ["address": address])
        }
    }
    
    // 3.1.3 Requesting the original account data for a delegate account from public key
    public class AccountGetForwardedFromPublicKey: NISGetRequest<AccountMetaDataPair> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, publicKey: String) {
            super.init(baseURL: baseURL, path: "/account/get/forwarded/from-public-key", parameters: ["publicKey": publicKey])
        }
    }
    
    // 3.1.4 Requesting the account status
    public class AccountStatus: NISGetRequest<AccountMetaData> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/status", parameters: ["address": address])
        }
    }

    // 3.1.5 Requesting transaction data for an account
    public class AccountTransfersIncoming: NISGetRequest<TransactionMetaDataPairs> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String, hash: String? = nil, id: Int? = nil) {
            super.init(baseURL: baseURL, path: "/account/transfers/incoming",
                       parameters: ["address": address, "hash": hash, "id": id])
        }
    }
    
    public class AccountTransfersOutgoing: NISGetRequest<TransactionMetaDataPairs> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String, hash: String? = nil, id: Int? = nil) {
            super.init(baseURL: baseURL, path: "/account/transfers/outgoing",
                       parameters: ["address": address, "hash": hash, "id": id])
        }
    }
    
    public class AccountTransfersAll: NISGetRequest<TransactionMetaDataPairs> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String, hash: String? = nil, id: Int? = nil) {
            super.init(baseURL: baseURL, path: "/account/transfers/all",
                       parameters: ["address": address, "hash": hash, "id": id])
        }
    }
    
    public class AccountUnconfirmedTransactions: NISGetRequest<UnconfirmedTransactionMetaDataPairs> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/unconfirmedTransactions", parameters: ["address": address])
        }
    }
    
    // 3.1.7 Requesting harvest info data for an account
    public class AccountHarvests: NISGetRequest<Harvests> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String, hash: String? = nil) {
            super.init(baseURL: baseURL, path: "/account/harvests",
                       parameters: ["address": address, "hash": hash])
        }
    }
    
    // 3.1.8 Retrieving account importances for accounts
    public class AccountImportances: NISGetRequest<Importances> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL) {
            super.init(baseURL: baseURL, path: "/account/importances")
        }
    }
    
    // 3.1.9 Retrieving namespaces that an account owns
    public class AccountNamespacePage: NISGetRequest<Namespaces> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String, parent: String? = nil, id: Int? = nil, pageSize: Int? = nil) {
            super.init(baseURL: baseURL, path: "/account/namespace/page",
                       parameters: ["address": address, "parent": parent, "id": id, "pageSize": pageSize])
        }
    }
    
    public class NamespaceMosaicDefintionPage: NISGetRequest<MosaicDefinitionMetaDataPairs> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, namespace: String, id: Int? = nil, pageSize: Int? = nil) {
            super.init(baseURL: baseURL, path: "/namespace/mosaic/definition/page",
                       parameters: ["namespace": namespace, "id": id, "pagesize": pageSize])
        }
    }
    
    // Retrieving mosaics that an account owns
    public class AccountMosaicOwned: NISGetRequest<Mosaics> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, address: String) {
            super.init(baseURL: baseURL, path: "/account/mosaic/owned", parameters: ["address": address])
        }
    }
    
    // 7.9.2 Sending the data to NIS
    public class TransactionAnnounce: NISPostRequest<NemAnnounceResult> {
        public init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, data: String, signature: String) {
            super.init(baseURL: baseURL, path: "/transaction/announce", parameters: ["data": data, "signature": signature])
        }
        
        public convenience init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, requestAnnounce: RequestAnnounce) {
            self.init(baseURL: baseURL, data: requestAnnounce.data, signature: requestAnnounce.signature)
        }
        
        public convenience init(baseURL: URL = NemSwiftConfiguration.defaultBaseURL, requestAnnounce: [UInt8], keyPair: KeyPair) {
            self.init(baseURL: baseURL, requestAnnounce: RequestAnnounce.generateRequestAnnounce(requestAnnounce: requestAnnounce, keyPair: keyPair))
        }

    }
}

