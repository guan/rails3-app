rvmrc = <<-RVMRC
rvm_gemset_create_on_use_flag=1
rvm gemset use #{app_name}
RVMRC

in_root do
  create_file ".rvmrc", rvmrc
end

empty_directory "lib/generators"
run "git clone --depth 0 http://github.com/leshill/rails3_app.git lib/generators"
remove_dir "lib/generators/.git"

gem "haml", ">= 3.0.0.rc.4"
gem "rspec-rails", ">= 2.0.0.beta.8", :group => :test
gem "factory_girl", ">= 1.2.4", :group => :test

generators = <<-GENERATORS

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => true, :views => false
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
GENERATORS

application generators

run 'curl -L http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js > public/javascripts/jquery.js'
run 'curl -L http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js > public/javascripts/jquery-ui.js'
run 'curl -L http://github.com/rails/jquery-ujs/raw/HEAD/src/rails.js > public/javascripts/rails.js'

jquery = <<-JQUERY
ActionView::Helpers::AssetTagHelper.register_javascript_expansion \
  :jquery => %w(jquery jquery-ui rails application)
JQUERY

initializer "jquery.rb", jquery

layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    = stylesheet_link_tag :all
    = javascript_include_tag :jquery
    = csrf_meta_tag
  %body
    = yield
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

in_root do
  git :init
  git :add => "."
end

docs = <<-DOCS

Run the following commands to complete the setup of #{app_name.humanize}:

% cd #{app_name}
% gem install bundler
% bundle install
% bundle lock
% script/rails generate rspec:install

DOCS

log docs