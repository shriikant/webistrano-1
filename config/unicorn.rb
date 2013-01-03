# -*- coding: undecided -*-
# What the timeout for killing busy workers is, in seconds
timeout 60
 
# Whether the app should be pre-loaded
preload_app true
 
# How many worker processes
worker_processes 4
 
# before/after forks
before_fork do |server, worker|
  sleep 1
end

after_fork do |server, worker|
  GC.disable
end

# ログ
stderr_path File.expand_path('log/unicorn_err.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn_out.log', ENV['RAILS_ROOT'])
