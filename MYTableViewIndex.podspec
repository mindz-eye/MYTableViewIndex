Pod::Spec.new do |s|
  s.name             = 'MYTableViewIndex'
  s.version          = '0.3.0'
  s.summary          = 'A pixel perfect replacement for UITableView section index, written in Swift.'

  s.description      = <<-DESC
MYTableViewIndex is a re-implementation of UITableView section index. This control is usually seen in apps displaying contacts, music tracks and other alphabetically sorted data. MYTableViewIndex completely replicates native iOS section index, but can also display images and has many customization capabilities.
                       DESC

  s.homepage         = 'https://github.com/mindz-eye/MYTableViewIndex'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Makarov Yuriy' => 'makarov.yuriy@gmail.com' }
  s.source           = { :git => 'https://github.com/mindz-eye/MYTableViewIndex.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mindZ_eYe'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MYTableViewIndex/**/*'
end
