# frozen_string_literal: true

SERVER_EXEC_PATH = '/app/minecraft/server-data'
START_CMD = ENV['START_CMD']
IS_MODDED = File.exist?("#{SERVER_EXEC_PATH}/startserver.sh")

backup_daemon_pid = fork do
  # Backup on start
  system 'ruby /app/minecraft/bin/backup.rb -i'
  system 'ruby /app/minecraft/bin/backup.rb'
end

child_pid = fork do
  system "chmod 755 #{SERVER_EXEC_PATH}/startserver.sh && #{SERVER_EXEC_PATH}/startserver.sh" if IS_MODDED
  system START_CMD unless IS_MODDED
end

trap('SIGTERM') do
  Process.kill('INT', backup_daemon_pid)
  Process.kill('INT', child_pid)

  # Backup on stop
  exec 'ruby /app/minecraft/bin/backup.rb -i'
end

trap('SIGINT') do
  Process.kill('INT', backup_daemon_pid)
  Process.kill('INT', child_pid)

  # Backup on stop
  exec 'ruby /app/minecraft/bin/backup.rb -i'
end

Process.wait(child_pid)
