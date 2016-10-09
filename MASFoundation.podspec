Pod::Spec.new do |s|

    s.name          = 'MASFoundation'
    s.version       = '1.2.01'
    s.summary       = 'The MASFoundation framework is the core iOS framework upon which Mobile App Service is built.'
    s.homepage      = "http://mas.ca.com"
    s.authors       = {
        'Britton Katnich' => 'britton.katnich@ca.com',
        'Luis Sanches' => 'luis.sanches@ca.com',
        'Robert Weber' => 'robert.weber@ca.com',
    }
    s.license       = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.platform      = :ios, '8.0'
    s.requires_arc  = true
    s.source        = { :git => 'https://github.com/CAAPIM/iOS-MAS-Foundation.git', :tag => s.version.to_s }
    s.public_header_files = 'MASFoundation/*.h'
    s.source_files = 'MASFoundation'
    

    s.subspec 'OpenSSL' do |openssl|
        openssl.preserve_paths = 'MASFoundation/Vendor/OpenSSL/include/openssl/*.h'
        openssl.vendored_libraries = 'MASFoundation/Vendor/OpenSSL/include/lib/libcrypto_iOS.a', 'MASFoundation/Vendor/OpenSSL/include/lib/libssl_iOS.a'
        openssl.libraries = 'ssl_iOS', 'crypto_iOS'
        openssl.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/MASFoundation/Vendor/OpenSSL/include/**" }
    end

end
