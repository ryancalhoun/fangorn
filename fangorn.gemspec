Gem::Specification.new {|s|
	s.name = 'fangorn'
	s.version = '0.0.1'
	s.licenses = ['MIT']
	s.summary = 'Haml + Sass + Javascript'
	s.description = 'Asset compiler for front-end assets.'
	s.homepage = 'https://github.com/ryancalhoun/fangorn'
	s.authors = ['Ryan Calhoun']
	s.email = ['ryanjamescalhoun@gmail.com']
  
	s.files = Dir["{bin,lib}/**/*"] + %w(LICENSE README.md)

  s.executables = s.files.grep(/^bin\//).map {|f| File.basename f}
}

