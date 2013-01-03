# What the timeout for killing busy workers is, in seconds
timeout 30
 
# Whether the app should be pre-loaded
preload_app true
 
# How many worker processes
worker_processes 2

stdout_path "tmp/unicorn-out.log"
stderr_path "tmp/unicorn-err.log"
