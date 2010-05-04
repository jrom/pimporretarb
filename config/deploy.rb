set :application, "pimporreta.org"
set :repository,  "git@github.com:jrom/pimporretarb.git"
set :deploy_to, "/home/jordi/apps/pimporreta"
set :deploy_via, :remote_cache
set :branch, "master"

set :user, "jordi"

set :use_sudo, false
ssh_options[:forward_agent] = true

set :scm, :git

role :web, "jrom.net"
role :app, "jrom.net"
role :db,  "jrom.net", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

set :normal_symlinks, %w(
  config/database.yml
)

namespace :symlinks do
  desc "Make all the damn symlinks"
  task :make, :roles => :app, :except => { :no_release => true } do
    commands = normal_symlinks.map do |path|
      "rm -rf #{release_path}/#{path} && \
       ln -s #{shared_path}/#{path} #{release_path}/#{path}"
    end

    run <<-CMD
      cd #{release_path} &&
      #{commands.join(" && ")}
    CMD
  end
end

after "deploy:update_code", "symlinks:make"

