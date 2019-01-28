Read this in other languages: [English](README.md), [日本語](README.ja.md)

# nem-swift

nem-swift is a client library for easy use of NEM API.

This library wraps HTTP requests to NIS(NEM Infrastructure Server) and HTTP responses from NIS.

This library also provides crypt related utilities like key pair generation signing and verifying.

## Sample

Sample projects are in [NemSwiftDemo](NemSwiftDemo) directory.

## Installation

Use Carthage or CocoaPods.

### Carthage

1. Insert `github "ryuta46/nem-swift"` to your Cartfile.
2. Run `carthage update`.
3. Add "NemSwift.framework" to Linked Frameworks and Libraries  
    TARGETS -> YourTarget -> Linked Frameworks and Libraries  
    Press "+" -> Add Other... -> Select "NemSwift.framework" in Carthage/Build/iOS

    ![Link NemSwift.framework](../assets/carthage_setup_link.png?raw=true)

4. Add Run Script in Build Phases  
    Build Phases -> Press "+" -> New Run Script Phase  
    Shell `/bin/sh`  
    Script `/usr/local/bin/carthage copy-frameworks`  
    Add "NemSwift.framework", "APIKit.framework", "Result.framework" and "CryptoSwift.framework" to input file

    ![Copy frameworks](../assets/carthage_setup_copy_framework.png?raw=true)

### CocoaPods

1. Insert `pod 'NemSwift'` to your Podfile
2. Run `pod update`
3. Open generated .xcworkspace file with Xcode.

## How to use

### Setup

#### Configure ATS

If you want to access to NIS with HTTP (not HTTPS) protocol, configure ATS (App Transport Security) in Info.plist file.

See [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35) for details.


#### Setup Library

nem-swift has global configurations in NemSwiftConfiguration class.

```swift
import NemSwift
...

// Default URL of NIS
NemSwiftConfiguration.defaultBaseURL = URL(string: "https://nismain.ttechdev.com:7891")!
// Log level
NemSwiftConfiguration.logLevel = .debug
```


### Account generation

'Account' generates a NEM account. Network version is required( for main network or test network).

```swift
let account = Account.generateAccount(network: .testnet)
```

If you have private key already, retrieve the account from the key.
```swift
let account = Account.repairAccount(privateKey, network: .testnet)
```

### Getting an account information

To get an account information,

```swift
import NemSwift
import APIKit
import Result

...

Session.send(NISAPI.AccountGet(address: account.address.value)) { result in
    switch result {
        case .success(let response):
            print("balance \(response.account.balance)")
        case .failure(let error):
            print(error)
    }
}
```

NISAPI has classes corresponding to NEM APIs.  
You can override NIS URL with baseURL parameter when you create a request.

```swift
Session.send(NISAPI.AccountGet(baseURL: URL(string:"http://customnis:7890")!,  address: account.address.value)) { result in
        ....
    }
}
```

### Creating a transaction

**When creating a transaction, you should get network time from the NIS and use it as timeStamp.**

First, get network time from the NIS
```swift
Session.send(NISAPI.NetworkTime()) { result in
    switch result {
        case .success(let response):
            timeStamp = response.receiveTimeStampBySeconds
        case .failure(let error):
            print(error)
        }
}
```

Next, create a transaction using the acquired network time as timeStamp.
```swift
// Create XEM transfer transaction
let transaction = TransferTransactionHelper.generateTransferRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    recipientAddress: recipient,
    amount: microXem)
```

The local time is used when the `timeStamp` parameter is omitted, but it may cause `FAILURE_TIMESTAMP_TOO_FAR_IN_FUTURE` error when the transaction is announced.

### Sending XEM and Mosaics

TransferTransactionHelper is an utility to create transactions which required account signing.

To send XEM,
```swift
// Create XEM transfer transaction
let transaction = TransferTransactionHelper.generateTransferRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    recipientAddress: recipient,
    amount: microXem)

// Sign the transaction
let signedTransaction = RequestAnnounce.generateRequestAnnounce(requestAnnounce: transaction, keyPair: account.keyPair)

// Send
Session.send(NISAPI.TransactionAnnounce(data: signedTransaction.data, signature: signedTransaction.signature)) { result in
    switch result {
        case .success(let response):
            print(response)
        case .failure(let error):
            print(error)
    }
}
```
Note that the amount specified above is micro nem unit. ( 1 XEM = 1,000,000 micro nem)

To send mosaic,
```swift
let mosaic = TransferMosaic(namespace: "mosaicNamespaceId",
                            mosaic: "mosaicName",
                            quantity: quantity,
                            supply: mosaicSupply,
                            divisibility: mosaicDivisibility)

// Create transfer transaction
let transaction = TransferTransactionHelper.generateMosaicTransferRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    recipientAddress: recipient,
    mosaics: [mosaic])
```

Mosaic's supply and divisibility are used to calculate minimum transaction fee.

You can get these parameters of mosaic with 'NamespaceMosaicDefinitionPage' and 'MosaicSupply' if you don't know them.

```swift
Session.send(NISAPI.NamespaceMosaicDefintionPage(namespace: "mosaicNameSpaceId")) { result in
    switch result {
        case .success(let response):
            for mosaicDefinition in response.data {
                if (mosaicDefinition.mosaic.id.name == "mosaicName") {
                    // divisibility = mosaicDefinition.mosaic.divisibility
                }
            }
```

```swift
Session.send(NISAPI.NamespaceMosaicDefintionPage(mosaicId: mosaicId)) { result in
    switch result {
        case .success(let response):
            // supply = response.supply

```

### Sending and Receiving message.

To send XEM with a plain text message,

```swift
let message = Array("message".utf8)

let transaction = TransferTransactionHelper.generateTransferRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    recipientAddress: recipient,
    amount: microXem,
    messageType: .plain,
    message: message)
```

With a encrypted message,

```swift
let message = Array("message".utf8)

let encryptedMessage = MessageEncryption.encrypt(
    senderKeys: account.keyPair, 
    receiverPublicKey: receiverPublicKey,
    message: message)

let transaction = TransferTransactionHelper.generateTransferRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    recipientAddress: recipient,
    amount: microXem,
    messageType: .secure,
    message: message)
```

You can read message from a transaction as follows

```swift
guard let payload = transaction?.transaction.message?.payload,
    let type = transaction?.transaction.message?.type {
    return
}

let messageBytes = ConvertUtil.toByteArray(payload)

let message: String
if (type == TransferTransactionHelper.MessageType.plain.rawValue) {
    message = String(bytes: messageBytes, encoding: .utf8)!
} else {
    let decryptedBytes = try MessageEncryption.decrypt(
        receiverKeys: account.keyPair,
        senderPublicKey: senderPublicKey,
        mergedEncryptedMessage: messageBytes)

    message = String(bytes: decryptedBytes, encoding: .utf8)!
}
```

### Multisig Related Transactions

Multisig related transactions(MultisigTransaction, MultisigSignatureTransaction, MultisigAggreageModificationTransaction) are created by MultisigTransactionHelper.

To change an account to multisig account,

```swift
let modificationRequest = MultisigTransactionHelper.generateAggregateModificationRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    modifications: [MultisigCosignatoryModification(modificationType: .add, cosignatoryAccount: signer.keyPair.publicKeyHexString())],
    minCosignatoriesRelativeChange: 1)

Session.send(NISAPI.TransactionAnnounce(requestAnnounce: modificationRequest, keyPair: account.keyPair)) { result in
    switch result {
        case .success(let response):
            print(response)
        case .failure(let error):
            print(error)
    }
}
```


To send XEM from multisig account,

```swift
// Create inner transaction of which transfers XEM
let transferTransaction = TransferTransactionHelper.generateTransfer(
    publicKey: MULTISIG_ACCOUNT_PUBLIC_KEY,
    network: .testnet,
    timeStamp: timeStamp,
    recipientAddress: recipientAddress,
    amount: 10
)
        
    
// Create multisig transaction
let multisigRequest = MultisigTransactionHelper.generateMultisigRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    innerTransaction: transferTransaction)


Session.send(NISAPI.TransactionAnnounce(requestAnnounce: multisigRequest, keyPair: account.keyPair)) { result in
    switch result {
        case .success(let response):
            print(response)
        case .failure(let error):
            print(error)
    }
}
```

And to sign the transaction,

```swift
// Get hash of the transaction to be signed.
Session.send(NISAPI.AccountUnconfirmedTransactions(address: signer.address.value)) { [weak self] result in
    switch result {
        case .success(let response):
            self?.unconfirmedTransactions = response
        case .failure(let error):
            print(error)
        }
    }
}

...
        
guard let hash = self.unconfirmedTransactions?.data.first?.meta.data else {
    return
}
    
// Sign the transaction
let signatureRequest = MultisigTransactionHelper.generateSignatureRequestAnnounce(
    publicKey: signer.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    otherHash: hash,
    otherAccount: MULTISIG_ACCOUNT_ADDRESS)
    

Session.send(NISAPI.TransactionAnnounce(requestAnnounce: signatureRequest, keyPair: signer.keyPair)) { result in
    switch result {
        case .success(let response):
            print(response)
        case .failure(let error):
            print(error)
    }
}
```

