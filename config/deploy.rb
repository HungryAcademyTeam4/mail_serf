# Configure these lines for your app prior to launch.
# Application Name is the folder it will deploy to.
# Script Name is the name of the logfile and the god script.
# Start Command is the command god will issue to start the process.

APPLICATION_NAME = "MailSerf"
SCRIPT_NAME = "mail_serf"
REPOSITORY = "git://github.com/HungryAcademyTeam4/mail_serf.git"
START_COMMAND = "unicorn /apps/#{APPLICATION_NAME}/current/config.ru -p 3020"

# Rainbows start example
# START_COMMAND = "rainbows /apps/#{APPLICATION_NAME}/current/faye.ru -c /apps/#{APPLICATION_NAME}/current/rainbows.conf -E production -p 9000"

# This assumes you want to launch to Falling Foundry.
# If you want to launch to Falling Garden, launch with
# DEPLOY_MODE="staging" cap deploy

PRODUCTION_SERVER = "fallingfoundry.com"
STAGING_SERVER = "fallinggarden.com"
MODE = ENV["DEPLOY_MODE"] || "production"
SERVER = MODE == "staging" ? STAGING_SERVER : PRODUCTION_SERVER


$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
server SERVER, :web, :db, :app, primary: true
set :user, "root"
set :application, APPLICATION_NAME

set :deploy_to, "/apps/#{application}"
set :deploy_via, :remote_cache

set :scm, "git"
set :repository, REPOSITORY
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :mailman do
  desc "Mailman::Start"
  task :start, :roles => [:app] do
    run "cd #{current_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon start"
  end
  
  desc "Mailman::Stop"
  task :stop, :roles => [:app] do
    run "cd #{current_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon stop"
  end
  
  desc "Mailman::Restart"
  task :restart, :roles => [:app] do
    mailman.stop
    mailman.start
  end
end

namespace :deploy do
  namespace :assets do
    task :precompile do
      logger.info "Skipping precompilation of assets"
    end
  end
end

namespace :deploy do
  task :mkdirs do
    run "mkdir /apps/#{application}/releases/current -p"
    run "mkdir /apps/god_scripts -p"
  end
  task :create_god_script do
    run %^cd /apps/god_scripts && touch #{SCRIPT_NAME}.rb && rm #{SCRIPT_NAME}.rb && touch #{SCRIPT_NAME}.rb^
    run %^echo God.watch do \\\|w\\\| >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.log = \\\"/#{SCRIPT_NAME}.log\\\" >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.name = \\\"#{SCRIPT_NAME}\\\" >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.start = \\\"#{START_COMMAND}\\\" >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.keepalive >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo end >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
  end
  task :bundle do
    run "cd /apps/#{application}/current && bundle install --system"
  end
  task :start do
    run "cd / && god load apps/god_scripts/#{SCRIPT_NAME}.rb"
    run "cd / && god start #{SCRIPT_NAME}"
  end
  task :stop do
    run "cd / && god stop #{SCRIPT_NAME}"
  end
  task :restart do
    stop
    start
  end
  task :ensure_god_running do
    run "cd / && god"
  end
  task :db_migrate do
    run "cd /apps/#{application}/current && rake db:create && rake db:migrate"
  end
  before "deploy:start", "deploy:ensure_god_running"
  before "deploy:stop", "deploy:ensure_god_running"
  before "deploy", "deploy:mkdirs"
  before "deploy", "deploy:create_god_script"
  #after "deploy", "deploy:db_migrate"
  after "deploy", "deploy:bundle"
  after "deploy", "deploy:start"
  after "deploy", "mailman:start"
end