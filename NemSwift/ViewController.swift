//
//  ViewController.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/15.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import UIKit
import APIKit
import NemSwift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
        let account = Account.generteAccount(network: .mainnet)
        print("address: \(account.address.value)")
        print("publicKey: \(account.keyPair.publicKeyHexString())")
        print("privateKey: \(account.keyPair.privateKeyHexString())")
        print("importKey: \(account.keyPair.importKey())")
        print("=======================")
        
        let repairAccount = Account.repairAccount(account.keyPair.importKey(), network: .testnet)
        print("publicKey by import key : \(repairAccount.keyPair.publicKeyHexString())")
 */
        let account = Account.repairAccount("c14f22807cc77ef58da8ff074ef3e11d778447d0d557a9cb168ac2e161f5229d", network: .testnet)
        print("address : \(account.address.value)")
        
/*
        Session.send(NISAPI.AccountGetFromPublicKey(publicKey: account.keyPair.publicKeyHexString())) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
 
        Session.send(NISAPI.AccountGet(address: account.address.value)) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
 */
        /*
        Session.send(NISAPI.AccountTransfersIncoming(address: "NCXIZQEARYTW2BGFHAPEZCIY5ILOUUJRC3VZH4MZ", hash: nil, id: nil)) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }*/
        
        /*
        let announce = TransferTransactionHelper.generateTransferRequestAnnounce(publicKey: account.keyPair.publicKey, network: .testnet, recepientAddress: account.address.value, amount: 0, messageTyep: .Plain, message: "送金テスト")
 */


        /*
        let mosaic = TransferMosaic(namespace: "daoka", mosaic: "daokasweep", quantity: 1, supply: 10, divisibility: 0)
        let mosaics = [mosaic]
 
        let announce = TransferTransactionHelper.generateMosaicTransferRequestAnnounce(publicKey: account.keyPair.publicKey, network: .testnet, recepientAddress: account.address.value, mosaics: mosaics, messageType: .Plain, message: "mosaic transfer test")

        let requestAnnounce = RequestAnnounce.generateRequestAnnounce(requestAnnounce: announce, keyPair: account.keyPair)

        Session.send(NISAPI.TransactionAnnounce(data: requestAnnounce.data, signature: requestAnnounce.signature)) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                
                switch error {
                case .responseError(let e as NISError):
                    print(e)
                default:
                    print(error)
                }
            }
        }
         */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

