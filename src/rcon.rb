# frozen_string_literal: true

def rcon(command)
  system "/app/minecraft/bin/mcrcon -H 127.0.0.1 -P 25575 -p #{ENV['RCON_PASSWORD']} \"#{command}\""
end
