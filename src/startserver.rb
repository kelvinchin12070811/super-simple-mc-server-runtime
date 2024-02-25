# frozen_string_literal: true

require 'fileutils'

SERVER_EXEC_PATH = '/app/minecraft/server-data'
START_CMD = ENV['START_CMD']
IS_MODDED = File.exist?("#{SERVER_EXEC_PATH}/startserver.sh")

child_pid = fork do
  system 'ruby /app/minecraft/bin/backup.rb -i'
  exec "chmod 755 #{SERVER_EXEC_PATH}/startserver.sh && #{SERVER_EXEC_PATH}/startserver.sh" if IS_MODDED
  exec START_CMD unless IS_MODDED
end

File.new('/app/minecraft/server-data/server.pid', 'w').write(child_pid.to_s)

trap('SIGTERM') do
  FileUtils.rm('/app/minecraft/server-data/server.pid')
  # Backup on stop
  exec 'ruby /app/minecraft/bin/backup.rb -i'
  Process.kill('INT', child_pid)
end

trap('SIGINT') do
  FileUtils.rm('/app/minecraft/server-data/server.pid')
  # Backup on stop
  exec 'ruby /app/minecraft/bin/backup.rb -i'
  Process.kill('INT', child_pid)
end

Process.wait(child_pid)
