Read this in other languages: [English](README.md), [日本語](README.ja.md)

# nem-swift

nem-swift は NEM のAPI を簡単に扱うためのライブラリです。

このライブラリは、NIS(NEM Infrastructure Server) に対してのHTTPリクエストと、NISからのHTTPのレスポンスのラッパーとして機能します。

また、このライブラリではキーペアの作成や署名、署名検証といった暗号化関連のユーティリティも提供します。

## サンプル

サンプルプロジェクトが [NemSwiftDemo](NemSwiftDemo) ディレクトリにあります。ご参照ください。

## インストール

Carthage か CocoaPods を利用できます。

### Carthage

1. Cartfile に `github "ryuta46/nem-swift"` を追加
2. `carthage update` を実行
3. "NemSwift.framework" を Linked Frameworks and Libraries に追加
    TARGETS -> YourTarget -> Linked Frameworks and Libraries  
    "+" をクリック -> Add Other... -> Carthage/Build/iOS にある "NemSwift.framework" を選択 

    ![Link NemSwift.framework](../assets/carthage_setup_link.png?raw=true)

4. Build Phases に Run Script を追加
    Build Phases -> "+" をクリック -> New Run Script Phase  
    Shell `/bin/sh`  
    Script `/usr/local/bin/carthage copy-frameworks`  
    "NemSwift.framework"、"APIKit.framework"、"CryptoSwift.framework" を input file として追加

    ![Copy frameworks](../assets/carthage_setup_copy_framework.png?raw=true)

### CocoaPods

1. Podfile に `pod 'NemSwift'` を追加
2. `pod update` を実行
3. 生成された .xcworkspace ファイルを Xcode で開く

## 使用方法

### セットアップ

#### ATS 設定

もし NIS に対して HTTP (非HTTPS) protocol でアクセスする場合、ATS (App Transport Security) の設定を Info.plist ファイルで行う必要があります。

詳細は [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35) を参照。


#### ライブラリのセットアップ

nem-swift は NemSwiftConfiguration にグローバルな設定を持っています。

```swift
import NemSwift
...

// Default URL of NIS
NemSwiftConfiguration.defaultBaseURL = URL(string: "https://nismain.ttechdev.com:7891")!
// Log level
NemSwiftConfiguration.logLevel = .debug
```


### アカウント作成

'Account' クラスで NEM のアカウントを作成します。Network バージョンの指定が必要です。( メインネットまたはテストネット)。

```swift
let account = Account.generateAccount(network: .testnet)
```

秘密鍵がすでにあるのであれば、その情報からアカウントを生成することも出来ます。
```swift
let account = Account.repairAccount(privateKey, network: .testnet)
```

### アカウント情報の取得

アカウント情報を取得する場合

```swift
import NemSwift
import APIKit

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

NISAPI 内に NEM の 各API に対応したクラスがあります。  
NIS の URL は baseURL パラメータで上書きできます。

```swift
Session.send(NISAPI.AccountGet(baseURL: URL(string:"http://customnis:7890")!,  address: account.address.value)) { result in
        ....
    }
}
```

### トランザクションの作成

**トランザクションを作成する際は、NISからネットワーク時間を取得して、それをタイムスタンプとして使う必要があります。**

最初に、NISからネットワーク時間を取得し、
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

次に、取得した時間を `timeStamp` としてトランザクション作成時に設定します。
```swift
// Create XEM transfer transaction
let transaction = TransferTransactionHelper.generateTransferRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: .testnet,
    timeStamp: timeStamp,
    recipientAddress: recipient,
    amount: microXem)
```

`timeStamp` パラメータが省略された場合はローカル時間が使われますが、その場合はトランザクションを送信した際に `FAILURE_TIMESTAMP_TOO_FAR_IN_FUTURE` エラーが発生する場合があります。

### XEM、モザイクの送信

送金など、署名が必要なトランザクションの生成は 'TransferTransactionHelper' を使います。

XEMを送金する場合
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
上記で指定している amount はマイクロ NEM 単位であることに注意してください。( 1 XEM = 1,000,000 マイクロ NEM)

モザイク送信をする場合

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

モザイクの供給量や可分性は、最低手数料を計算する際に用いられます。

もしそれらの値が不明な場合は、'NamespaceMosaicDefinitionPage' と 'MosaicSupply' を使って取得することが出来ます。

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


### メッセージの送受信

平文のメッセージを含めて XEM の送信を行う場合

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

暗号化メッセージを含めて XEM の送信を行う場合

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

受信したトランザクションからメッセージを読み取るには、下記のように実装します。

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

### マルチシグ関連のトランザクション

マルチシグ関連のトランザクション(マルチシグトランザクション、マルチシグ署名トランザクション、マルチシグ集計変更トランザクション) の生成は 'MultigisTransactionHelper' を使います。

アカウントをマルチシグに変更する場合

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


マルチシグアカウントから XEM を送金する場合

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

そしてそれに署名する場合

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

