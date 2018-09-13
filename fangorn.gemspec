Gem::Specification.new {|s|
	s.name = 'fangorn'
	s.version = '0.0.19'
	s.licenses = ['MIT']
	s.summary = 'Haml + Sass + Javascript'
	s.description = 'Asset compiler for front-end assets.'
	s.homepage = 'https://github.com/ryancalhoun/fangorn'
	s.authors = ['Ryan Calhoun']
	s.email = ['ryanjamescalhoun@gmail.com']
  
	s.files = Dir["{bin,lib}/**/*"] + %w(LICENSE README.md)

  s.executables = s.files.grep(/^bin\//).map {|f| File.basename f}

  s.add_runtime_dependency 'listen', '~> 3', '>= 3'
  s.add_runtime_dependency 'haml', '~> 4', '>= 4'
  s.add_runtime_dependency 'sass', '~> 3', '>= 3'
  s.add_runtime_dependency 'uglifier', '~> 4', '>= 4'
}

