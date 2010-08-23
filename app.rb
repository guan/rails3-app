rvmrc = <<-RVMRC
rvm_gemset_create_on_use_flag=1
rvm gemset use #{app_name}
RVMRC

create_file ".rvmrc", rvmrc

gitignore = <<-GITIGNORE
*~
.DS_Store
.bundle
config/database.yml
db/*.db
db/*.sql
log/*.log
tmp/**/*
GITIGNORE

run 'rm .gitignore'
create_file ".gitignore", gitignore

gemfile = <<-GEMFILE

gem 'haml-rails', ">= 0.0.2"

# Console display helpers
gem 'awesome_print'
gem 'looksee'
gem 'wirble'

group :test do
  gem 'factory_girl_rails', '>= 1.0.0'
  gem 'rspec-integration', '>= 2.0.0.beta.12'
  gem 'ZenTest'
  gem 'autotest-rails'
  gem 'spork'
  gem 'faker'
end

group :test, :development do
  gem 'factory_girl_generator', '>= 0.0.1'
  gem 'rspec-rails', '>= 2.0.0.beta.12'
end

group :test, :development, :staging do
  # For debugging, use one of the following
  # gem 'ruby-debug'   # For Ruby 1.8
  # gem 'ruby-debug19' # For Ruby 1.9
end
GEMFILE

append_file 'Gemfile', gemfile

generators = <<-GENERATORS

    config.generators do |g|
      g.test_framework :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true
    end
GENERATORS

application generators

get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js",  "public/javascripts/jquery.js"
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js", "public/javascripts/jquery-ui.js"
get "http://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

gsub_file 'config/application.rb', 'config.action_view.javascript_expansions[:defaults] = %w()', 'config.action_view.javascript_expansions[:defaults] = %w(jquery.js jquery-ui.js rails.js)'

run "cp config/database.yml config/database.yml.example"

layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    = stylesheet_link_tag :all
    = javascript_include_tag :defaults
    = csrf_meta_tag
  %body
    = yield
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

create_file "log/.gitkeep"
create_file "tmp/.gitkeep"

git :init
git :add => '.'

docs = <<-DOCS

Note that the DEBUG gems have been commented out in the Gemfile
Uncomment the gem that corresponds to your Ruby version

Run the following commands to complete the setup of #{app_name.humanize}:

% cd #{app_name}
% gem install bundler --pre
% bundle install
% script/rails generate rspec:install

DOCS

log docs
