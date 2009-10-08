# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{data_frame}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Richards"]
  s.date = %q{2009-10-08}
  s.default_executable = %q{plain_frame}
  s.description = %q{Data Frames with memoized transpose}
  s.email = %q{davidlamontrichards@gmail.com}
  s.executables = ["plain_frame"]
  s.files = ["README.rdoc", "VERSION.yml", "bin/plain_frame", "lib/data_frame", "lib/data_frame/arff.rb", "lib/data_frame/callback_array.rb", "lib/data_frame/core", "lib/data_frame/core/column_management.rb", "lib/data_frame/core/filter.rb", "lib/data_frame/core/import.rb", "lib/data_frame/core/pre_process.rb", "lib/data_frame/core/saving.rb", "lib/data_frame/core/training.rb", "lib/data_frame/data_frame.rb", "lib/data_frame/id3.rb", "lib/data_frame/kmeans.rb", "lib/data_frame/labels_from_uci.rb", "lib/data_frame/mlp.rb", "lib/data_frame/model.rb", "lib/data_frame/parameter_capture.rb", "lib/data_frame/sbn.rb", "lib/data_frame/transposable_array.rb", "lib/data_frame.rb", "lib/ext", "lib/ext/array.rb", "lib/ext/open_struct.rb", "lib/ext/string.rb", "lib/ext/symbol.rb", "spec/data_frame", "spec/data_frame/arff_spec.rb", "spec/data_frame/callback_array_spec.rb", "spec/data_frame/core", "spec/data_frame/core/column_management_spec.rb", "spec/data_frame/core/filter_spec.rb", "spec/data_frame/core/import_spec.rb", "spec/data_frame/core/pre_process_spec.rb", "spec/data_frame/core/saving_spec.rb", "spec/data_frame/core/training_spec.rb", "spec/data_frame/data_frame_spec.rb", "spec/data_frame/id3_spec.rb", "spec/data_frame/model_spec.rb", "spec/data_frame/parameter_capture_spec.rb", "spec/data_frame/transposable_array_spec.rb", "spec/data_frame_spec.rb", "spec/ext", "spec/ext/array_spec.rb", "spec/fixtures", "spec/fixtures/basic.csv", "spec/fixtures/discrete_testing.csv", "spec/fixtures/discrete_training.csv", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/davidrichards/data_frame}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Data Frames with memoized transpose}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

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
