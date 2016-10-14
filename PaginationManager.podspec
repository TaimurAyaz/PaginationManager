Pod::Spec.new do |s|
  s.name             = 'PaginationManager'
  s.version          = '1.0.1'
  s.summary          = 'PaginationManager makes it super easy to add pagination to any scrollView.'

  s.description      = <<-DESC
PaginationManager makes it super easy to add pagination to any scrollView. It observes the current scroll offset and informs the receiver when the offset surpasses a given threshold.
                       DESC

  s.homepage         = 'https://github.com/TaimurAyaz/PaginationManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TaimurAyaz' => '' }
  s.source           = { :git => 'https://github.com/TaimurAyaz/PaginationManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/*'
end
