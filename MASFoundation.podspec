Pod::Spec.new do |s|

    s.version       = '1.2.02'
    s.summary       = 'The MASFoundation framework is the core iOS framework upon which Mobile App Service is built.'
    s.homepage      = "http://mas.ca.com"
    s.authors       = {'Luis Sanches' => 'luis.sanches@ca.com'}
    s.license       = {:type => 'MIT', :file => 'LICENSE'}
    s.platform      = :ios, '8.0'
    s.requires_arc  = true
    s.source        = { :git => 'https://github.com/CAAPIM/iOS-MAS-Foundation.git', :tag => s.version.to_s }

    s.subspec 'Classes' do |classes|
        classes.public_header_files   = 'MASFoundation/Classes/**/*.h'
        classes.source_files          = 'MASFoundation/Classes/**/*'
    end

    s.subspec 'Vendor' do |vendor|
        vendor.subspec 'OpenSSL' do |openssl|
            openssl.public_header_files   = 'MASFoundation/Vendor/**/*.h'
            openssl.source_files          = 'MASFoundation/Vendor/**/*'
            openssl.preserve_paths = 'MASFoundation/Vendor/OpenSSL/include/openssl/*.h'
            openssl.vendored_libraries = 'MASFoundation/Vendor/OpenSSL/include/lib/libcrypto_iOS.a', 'MASFoundation/Vendor/OpenSSL/include/lib/libssl_iOS.a'
            openssl.libraries = 'ssl_iOS', 'crypto_iOS'
            openssl.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/MASFoundation/Vendor/OpenSSL/include/**" }
        end
    end
end
