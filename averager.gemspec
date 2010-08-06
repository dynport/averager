# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{averager}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tobias Schwab"]
  s.date = %q{2010-08-06}
  s.description = %q{RubyGem to track long running processes.}
  s.email = ["tobias.schwab@dynport.de"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/averager.rb", "script/console", "script/destroy", "script/generate", "spec/averager_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/time_travel.rb", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/tobstarr/averager}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{averager}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{RubyGem to track long running processes.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.1"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.1"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.1"])
  end
end
