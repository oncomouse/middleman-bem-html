# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-bem-html"
  s.version     = "1.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Pilsch"]
  s.email       = ["apilsch@tamu.edu"]
  s.homepage    = "http://andrew.pilsch.com"
  s.summary     = %q{Middleman extension to use bem_html and css_dead_class to add BEM class tags to HTML objects that have attributes (bem-block, bem-element, bem-modifiers).}
  # s.description = %q{A longer description of your extension}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", ["~> 4"])
  s.add_runtime_dependency("bem_html", ["~> 1"])
  s.add_runtime_dependency("css_dead_class", ["~> 1"])
  
  s.license = "ISC"
  
  # Additional dependencies
  # s.add_runtime_dependency("gem-name", "gem-version")
end
