Read this in other languages: [English](README.md), [日本語](README.ja.md)

# nem-swift

nem-swift は NEM(New Economy Movement) のAPI を簡単に扱うためのライブラリです。

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
    "NemSwift.framework"、"APIKit.framework"、"Result.framework"、"CryptoSwift.framework" を input file として追加

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
NemSwiftConfiguration.logLevel = NemSwiftConfiguration.LogLevel.debug
```


### アカウント作成

'Account' クラスで NEM のアカウントを作成します。Network バージョンの指定が必要です。( メインネットまたはテストネット)。

```swift
let account = Account.generateAccount(network: Address.Network.testnet)
```

秘密鍵がすでにあるのであれば、その情報からアカウントを生成することも出来ます。
```swift
let account = Account.repairAccount(privateKey, network: Address.Network.testnet)
```

### アカウント情報の取得

アカウント情報を取得する場合

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

NISAPI 内に NEM の 各API に対応したクラスがあります。  
NIS の URL は baseURL パラメータで上書きできます。

```swift
Session.send(NISAPI.AccountGet(baseURL: URL(string:"http://customnis:7890")!,  address: account.address.value)) { result in
        ....
    }
}
```

### Sending XEM and Mosaics

送金など、署名が必要なトランザクションの生成は 'TransferTransactionHelper' を使います。

XEMを送金する場合
```swift
// Create XEM transfer transaction
let transaction = TransferTransactionHelper.generateTransferRequestAnnounce(
    publicKey: account.keyPair.publicKey,
    network: TransactionHelper.Network.testnet,
    recipientAddress: recipient,
    amount: microXem,
    messageType: TransferTransactionHelper.MessageType.Plain,
    message: "")

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
    network: TransactionHelper.Network.testnet,
    recipientAddress: recipient,
    mosaics: [mosaic],
    messageType: TransferTransactionHelper.MessageType.Plain,
    message: "")
```

モザイクの供給量や可分性は、最低手数料を計算する際に用いられます。

もしそれらの値が不明な場合は、'NamespaceMosaicDefinitionPage' を使って取得することが出来ます。

```swift
Session.send(NISAPI.NamespaceMosaicDefintionPage(namespace: "mosaicNameSpaceId")) { result in
    switch result {
        case .success(let response):
            for mosaicDefinition in response.data {
                if (mosaicDefinition.mosaic.id.name == "mosaicName") {
                    // supply =  mosaicDefinition.mosaic.initialSupply
                    // divisibility = mosaicDefinition.mosaic.divisibility
                }
            }

```

