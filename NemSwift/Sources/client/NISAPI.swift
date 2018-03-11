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
    
    // 3.1.2 Requesting the account data
    struct AccountGet: NISRequest {
        typealias Response = AccountMetaDataPair
        let method: HTTPMethod = .get
        let path: String = "/account/get"
        var parameters: Any? {
            return ["address": address]
        }
        
        let address: String
    }
    
    // 3.1.2 Requesting the account data from public key
    struct AccountGetFromPublicKey: NISRequest {
        typealias Response = AccountMetaDataPair
        let method: HTTPMethod = .get
        let path: String = "/account/get/from-public-key"
        var parameters: Any? {
            return ["publicKey": publicKey]
        }
        
        let publicKey: String
    }
    
    // 3.1.3 Requesting the original account data for a delegate account
    struct AccountGetForwarded: NISRequest {
        typealias Response = AccountMetaDataPair
        let method: HTTPMethod = .get
        let path: String = "/account/get/forwarded"
        var parameters: Any? {
            return ["address": address]
        }
        
        let address: String
    }
    
    // 3.1.3 Requesting the original account data for a delegate account from public key
    struct AccountGetForwardedFromPublicKey: NISRequest {
        typealias Response = AccountMetaDataPair
        let method: HTTPMethod = .get
        let path: String = "/account/get/from-public-key"
        var parameters: Any? {
            return ["publicKey": publicKey]
        }
        
        let publicKey: String
    }
    
    // 3.1.4 Requesting the account status
    struct AccountStatus: NISRequest {
        typealias Response = AccountMetaData
        let method: HTTPMethod = .get
        let path: String = "/account/status"
        var parameters: Any? {
            return ["address": address]
        }
        
        let address: String
    }
    
    // 3.1.5 Requesting transaction data for an account
    struct AccountTransfersIncoming: NISRequest {
        typealias Response = TransactionMetaDataPairs
        let method: HTTPMethod = .get
        let path: String = "/account/transfers/incoming"
        var parameters: Any? {
            var params = ["address": address]
            if let hash = hash {
                params["hash"] = hash
            }
            if let id = id {
                params["id"] = id
            }
            return params
        }
        
        let address: String
        let hash: String?
        let id: String?
    }
    
    struct AccountTransfersOutgoing: NISRequest {
        typealias Response = TransactionMetaDataPairs
        let method: HTTPMethod = .get
        let path: String = "/account/transfers/outgoing"
        var parameters: Any? {
            var params = ["address": address]
            if let hash = hash {
                params["hash"] = hash
            }
            if let id = id {
                params["id"] = id
            }
            return params
        }
        
        let address: String
        let hash: String?
        let id: String?
    }
    
    struct AccountTransfersAll: NISRequest {
        typealias Response = TransactionMetaDataPairs
        let method: HTTPMethod = .get
        let path: String = "/account/transfers/all"
        var parameters: Any? {
            var params = ["address": address]
            if let hash = hash {
                params["hash"] = hash
            }
            if let id = id {
                params["id"] = id
            }
            return params
        }
        
        let address: String
        let hash: String?
        let id: String?
    }
    
    struct AccountUnconfirmedTransactions: NISRequest {
        typealias Response = UnconfirmedTransactionMetaDataPairs
        let method: HTTPMethod = .get
        let path: String = "/account/unconfirmedTransactions"
        var parameters: Any? {
            return ["address": address]
        }
        
        let address: String
    }
    
    // 3.1.7 Requesting harvest info data for an account
    struct AccountHarvests: NISRequest {
        typealias Response = Harvests
        let method: HTTPMethod = .get
        let path: String = "/account/harvests"
        var parameters: Any? {
            return ["address": address, "hash": hash]
        }
        
        let address: String
        let hash: String
    }
    
    // 3.1.8 Retrieving account importances for accounts
    struct AccountImportances: NISRequest {
        typealias Response = Importances
        let method: HTTPMethod = .get
        let path: String = "/account/importances"
    }
    
    // 3.1.9 Retrieving namespaces that an account owns
    struct AccountNamespacePage: NISRequest {
        typealias Response = Namespaces
        let method: HTTPMethod = .get
        let path: String = "/account/namespace/page"
        
        var parameters: Any? {
            var params = ["address": address]
            if let parent = parent {
                params["parent"] = parent
            }
            if let id = id {
                params["id"] = id
            }
            if let pageSize = pageSize {
                params["pageSize"] = pageSize
            }
            
            return params
        }
        
        let address: String
        let parent: String?
        let id: String?
        let pageSize: String?
    }
    
    struct NamespaceMosaicDefintionPage: NISRequest {
        typealias Response = MosaicDefinitionMetaDataPairs
        let method: HTTPMethod = .get
        let path: String = "/namespace/mosaic/definition/page"
        
        var parameters: Any? {
            var params = ["namespace": namespace]
            if let id = id {
                params = ["id": id]
            }
            if let pagesize = pagesize {
                params["pagesize"] = pagesize
            }
            
            return params
        }
        
        let namespace: String
        let id: String?
        let pagesize: String?
    }
    
    // Retrieving mosaics that an account owns
    struct AccountMosaicOwned: NISRequest {
        typealias Response = Mosaics
        let method: HTTPMethod = .get
        let path: String = "/account/mosaic/owned"
        
        var parameters: Any? {
            return ["address": address]
        }
        
        let address: String
    }
    
    // 7.9.2 Sending the data to NIS
    struct TransactionAnnounce: NISRequest {
        typealias Response =  NemAnnounceResult
        let method: HTTPMethod = .post
        let path = "/transaction/announce"
        
        var parameters: Any? {
            return ["data": data, "signature": signature]
        }
        
        let data: String
        let signature: String
    }
}
