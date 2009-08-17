# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{data_frame}
  s.version = "0.0.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Richards"]
  s.date = %q{2009-08-16}
  s.description = %q{Data Frames with memoized transpose}
  s.email = %q{davidlamontrichards@gmail.com}
  s.files = ["README.rdoc", "VERSION.yml", "lib/data_frame", "lib/data_frame/callback_array.rb", "lib/data_frame/transposable_array.rb", "lib/data_frame.rb", "lib/ext", "lib/ext/open_struct.rb", "lib/ext/string.rb", "lib/ext/symbol.rb", "spec/data_frame", "spec/data_frame/callback_array_spec.rb", "spec/data_frame/transposable_array_spec.rb", "spec/data_frame_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/davidrichards/data_frame}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Data Frames with memoized transpose}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<davidrichards-just_enumerable_stats>, [">= 0"])
      s.add_runtime_dependency(%q<fastercsv>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<davidrichards-just_enumerable_stats>, [">= 0"])
      s.add_dependency(%q<fastercsv>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<davidrichards-just_enumerable_stats>, [">= 0"])
    s.add_dependency(%q<fastercsv>, [">= 0"])
  end
end
