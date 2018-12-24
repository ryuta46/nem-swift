## Version 0.4.0

2018-12-24

* Add: Network time API
* Add: Namespace API
* Fix: Typo.
    * NamespaceMosaicDefintionPage -> NamespaceMosaicDefinitionPage
    * SignatureTransction -> SignatureTransaction

## Version 0.3.2

2018-11-14

* Fix: Sort mosaic list before serialization.

## Version 0.3.1

2018-09-19

* Fix: Some APIs does not work on 32bit environment.

## Version 0.3.0

2018-08-13

* BREAKING CHANGE: Type of message is changed from string to byte array to accept encrypted bytes.  
        In plain text message, pass UTF-8 byte array by using `Array("message".utf8)`. 
See [README](README.md) for more details.

* Add: Message Encryption


## Version 0.2.0

2018-08-03

* Add: Multisig related transactions.

## Version 0.1.0

2018-07-19

* First release.

