Pod::Spec.new do |s|

    s.name          = 'MASFoundation'
    s.version       = 'MAS-1.2.00-CR1'
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
    s.source        = { :git => 'https://github.com/CAAPIM/iOS-MAS-Foundation.git', :tag => s.version }
    s.vendored_frameworks = 'MASFoundation.framework'

end
