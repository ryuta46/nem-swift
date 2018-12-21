//
//  ViewController.swift
//  NemSwiftDemo
//
//  Created by Taizo Kusuda on 2018/07/15.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import UIKit
import NemSwift
import APIKit
import Result

class Constants {
    static let DEFAULT_BASE_URL = "https://nistest.ttechdev.com:7891"
    static let KEY_PRIVATE_KEY = "PRIVATE_KEY"
    static let MOSAIC_NAMESPACE_ID = "ttech"
    static let MOSAIC_NAME = "ryuta"
}

class ViewController: UIViewController {
    @IBOutlet weak var textAddress: UILabel!
    @IBOutlet weak var textMessage: UITextView!

    lazy var account: Account = setupAccount()

    var mosaicSupply: UInt64? = nil
    var mosaicDivisibility: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Sets NIS URL
        NemSwiftConfiguration.defaultBaseURL = URL(string: Constants.DEFAULT_BASE_URL)!
        // Sets log level
        NemSwiftConfiguration.logLevel = NemSwiftConfiguration.LogLevel.debug

        textAddress.text = account.address.value

        fetchAccountInfo()

        // Fetch mosaic info to calculate transfer fee of mosaic
        fetchMosaicDefinition()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTouchedAccountInfo(_ sender: Any) {
        fetchAccountInfo()
    }
    @IBAction func onTouchedSendXem(_ sender: Any) {
        let alert = UIAlertController(title: "Send XEM", message: "Input Address and Micro NEM", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.keyboardType = .asciiCapable
            textField.placeholder = "Receiver Address"
        }
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Micro NEM"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self](action:UIAlertAction!) -> Void in
            guard let weakSelf = self else {
                return
            }
            let addressField = alert.textFields![0] as UITextField
            let microXemField = alert.textFields![1] as UITextField
            guard let address = addressField.text,
                let microXemText = microXemField.text,
                let microXem = Int(microXemText) else {
                    print("Failed to analyze input")
                    return
            }
            weakSelf.textMessage.text = ""
            weakSelf.fetchServerTimeStamp{ timeStamp in
                weakSelf.sendXem(address, UInt64(microXem), timeStamp)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in }

        alert.addAction(cancelAction)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }
    @IBAction func onTouchedMosaicInfo(_ sender: Any) {
        fetchMosaicInfo()
    }
    @IBAction func onTouchedSendMosaic(_ sender: Any) {
        let alert = UIAlertController(title: "Send Mosaic", message: "Input Address and Quantity", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.keyboardType = .asciiCapable
            textField.placeholder = "Receiver Address"
        }
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Quantity"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self](action:UIAlertAction!) -> Void in
            guard let weakSelf = self else {
                return
            }
            let addressField = alert.textFields![0] as UITextField
            let quantityField = alert.textFields![1] as UITextField
            guard let address = addressField.text,
                let quantityText = quantityField.text,
                let quantity = Int(quantityText) else {
                    print("Failed to analyze input")
                    return
            }
            weakSelf.textMessage.text = ""
            weakSelf.fetchServerTimeStamp{ timeStamp in
                weakSelf.sendMosaic(address, UInt64(quantity), timeStamp)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in }

        alert.addAction(cancelAction)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    private func setupAccount() -> Account {
        if let privateKey = loadPrivatekey() {
            return Account.repairAccount(privateKey, network: Address.Network.testnet)
        } else {
            let account = Account.generateAccount(network: Address.Network.testnet)
            savePrivateKey(privateKey: account.keyPair.importKey())
            return account
        }
    }

    private func clearMessage() {
        textMessage.text = ""
    }

    private func showMessage(_ message: String) {
        textMessage.text.append(message + "\n")
    }

    private func fetchAccountInfo() {
        clearMessage()
        Session.send(NISAPI.AccountGet(address: account.address.value)) { [weak self] result in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let response):
                weakSelf.showMessage("balance \(response.account.balance)")
            case .failure(let error):
                switch error {
                case .responseError(let e as NISError):
                    print(e)
                default:
                    print(error)
                }
            }

        }
    }

    private func fetchMosaicInfo() {
        clearMessage()
        Session.send(NISAPI.AccountMosaicOwned(address: account.address.value)) { [weak self] result in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let response):
                for mosaic in response.data {
                    weakSelf.showMessage("\(mosaic.mosaicId.namespaceId):\(mosaic.mosaicId.name) \(mosaic.quantity)")
                }
            case .failure(let error):
                switch error {
                case .responseError(let e as NISError):
                    print(e)
                default:
                    print(error)
                }
            }
        }
    }
    
    private func fetchMosaicDefinition(from id: Int? = nil) {
        Session.send(NISAPI.NamespaceMosaicDefintionPage(namespace: Constants.MOSAIC_NAMESPACE_ID, id: id)) { [weak self] result in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let response):
                for mosaicDefinition in response.data {
                    if (mosaicDefinition.mosaic.id.name == Constants.MOSAIC_NAME) {
                        weakSelf.mosaicSupply = mosaicDefinition.mosaic.initialSupply
                        weakSelf.mosaicDivisibility = mosaicDefinition.mosaic.divisibility
                    }
                }
                print("mosaic supply: \(String(describing: weakSelf.mosaicSupply))")
                print("mosaic divisibility: \(String(describing: weakSelf.mosaicDivisibility))")

                if !response.data.isEmpty && (weakSelf.mosaicSupply != nil || weakSelf.mosaicDivisibility != nil) {
                    weakSelf.fetchMosaicDefinition(from: response.data.last!.meta.id)
                }
            case .failure(let error):
                switch error {
                case .responseError(let e as NISError):
                    print(e)
                default:
                    print(error)
                }
            }
        }

    }
    
    private func fetchServerTimeStamp(handler: @escaping (_ timeStamp: UInt32) -> Void) {
        Session.send(NISAPI.NetworkTime()) { result in
            switch result {
            case .success(let response):
                handler(response.receiveTimeStampBySeconds)
            case .failure(let error):
                switch error {
                case .responseError(let e as NISError):
                    print(e)
                default:
                    print(error)
                }
            }
        }
    }

    private func sendXem(_ recipientAddress: String, _ microXem: UInt64, _ timeStamp: UInt32) {
        clearMessage()
        // Create transfer transaction
        let transaction = TransferTransactionHelper.generateTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: TransactionHelper.Network.testnet,
            timeStamp: timeStamp,
            recipientAddress: recipientAddress,
            amount: microXem)

        // Sign the transaction
        let signedTransaction = RequestAnnounce.generateRequestAnnounce(requestAnnounce: transaction, keyPair: account.keyPair)

        // Send
        Session.send(NISAPI.TransactionAnnounce(data: signedTransaction.data, signature: signedTransaction.signature)) { [weak self] result in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let response):
                weakSelf.showMessage("result \(response.message)")
            case .failure(let error):
                switch error {
                case .responseError(let e as NISError):
                    print(e)
                default:
                    print(error)
                }
            }
        }
    }

    private func sendMosaic(_ recipientAddress: String, _ quantity: UInt64, _ timeStamp: UInt32) {
        clearMessage()

        guard let mosaicSupply = mosaicSupply,
            let mosaicDivisibility = mosaicDivisibility else {
                return
        }

        let mosaic = TransferMosaic(namespace: Constants.MOSAIC_NAMESPACE_ID,
                                    mosaic: Constants.MOSAIC_NAME,
                                    quantity: quantity,
                                    supply: mosaicSupply,
                                    divisibility: mosaicDivisibility)

        // Create transfer transaction
        let transaction = TransferTransactionHelper.generateMosaicTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: TransactionHelper.Network.testnet,
            timeStamp: timeStamp,
            recipientAddress: recipientAddress,
            mosaics: [mosaic])

        // Sign the transaction
        let signedTransaction = RequestAnnounce.generateRequestAnnounce(requestAnnounce: transaction, keyPair: account.keyPair)

        // Send
        Session.send(NISAPI.TransactionAnnounce(data: signedTransaction.data, signature: signedTransaction.signature)) { [weak self] result in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let response):
                weakSelf.showMessage("result \(response.message)")
            case .failure(let error):
                switch error {
                case .responseError(let e as NISError):
                    print(e)
                default:
                    print(error)
                }
            }
        }
    }

    private func loadPrivatekey() -> String? {
        return UserDefaults.standard.string(forKey: Constants.KEY_PRIVATE_KEY)
    }

    private func savePrivateKey(privateKey: String) {
        UserDefaults.standard.set(privateKey, forKey: Constants.KEY_PRIVATE_KEY)
    }


}

