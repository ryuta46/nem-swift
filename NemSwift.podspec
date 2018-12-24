Pod::Spec.new do |s|
  s.name         = "NemSwift"
  s.version      = "0.4.0"
  s.summary      = "client library for easy use of NEM API"
  s.description  = <<-DESC
                  - NemSwift wraps HTTP requests to NIS(NEM Infrastructure Server) and HTTP responses from NIS.
                  - NemSwift provides crypt related utilities like key pair generation signing and verifying.
                   DESC

  s.homepage     = "https://github.com/ryuta46/nem-swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "ryuta46" => "ryuta46g@gmail.com" }
  s.social_media_url   = "https://twitter.com/ryuta461"

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/ryuta46/nem-swift.git", :tag => s.version, :submodules => true }

  s.source_files  = "NemSwift/Sources/ed25519_sha3_512.{c,h}", "NemSwift/Sources/message_encryption.{c,h}", "NemSwift/Sources/ed25519/src/*.{c,h}", "NemSwift/Sources/RHash/librhash/{ripemd-160,byte_order,sha3}.c", "NemSwift/Sources/RHash/librhash/{ripemd-160,byte_order,sha3,ustd}.h", "NemSwift/NemSwift.h" , "NemSwift/**/*.swift" 
  s.public_header_files = "NemSwift/Sources/ed25519_sha3_512.h", "NemSwift/Sources/message_encryption.h", "NemSwift/Sources/ed25519/src/ed25519.h", "NemSwift/NemSwift.h" 

  
  s.requires_arc = true

  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '"USE_KECCAK"' }

  s.dependency 'APIKit' 
  s.dependency 'CryptoSwift'
end
