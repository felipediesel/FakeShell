ROOT = File.dirname(__FILE__)

require "yaml"
require "#{ROOT}/command"
require "#{ROOT}/file_system"
require "#{ROOT}/processes"

class Shell

  def initialize
    welcome
    FileSystem.load
  end

  def welcome
    puts ""
    puts "Este é um protótipo de Shell apenas em memória."
    puts ""
    puts "Digite help para ajuda."
  end

  def start
    wait_command
  end

  def wait_command
    print "/#{FileSystem::pwd.join('/')} $ "
    command = Command.new(gets.chomp, self)

    wait_command unless command.exit?
  end

end

s = Shell.new
s.start
