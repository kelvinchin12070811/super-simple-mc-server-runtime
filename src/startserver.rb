# frozen_string_literal: true

puts 'Starting server'

SERVER_EXEC_PATH = '/app/minecraft/server-data'
START_CMD = ENV['START_CMD']
IS_MODDED = File.exist?("#{SERVER_EXEC_PATH}/startserver.sh")

exec "chmod 755 #{SERVER_EXEC_PATH}/startserver.sh && #{SERVER_EXEC_PATH}/startserver.sh" if IS_MODDED
exec START_CMD unless IS_MODDED
