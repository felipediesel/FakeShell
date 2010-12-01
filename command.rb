class Command
  def initialize(c, shell)
    return if c.nil? or c == ''

    args = c.split
    command = args.delete_at 0
    execute(command, args)
  end

  def execute(command, args)
    if respond_to?(command)
      case method(command).arity
        when 0 then send(command)
        when 1 then send(command, args[0])
        when 2 then send(command, args[0], args[1])
      end
    else
      run(command)
    end
  end

  def ls
    FileSystem::current_dir.each do |name, attr|
      puts name.ljust(20) + (attr.is_a?(Hash) ? '/' : attr.collect { |a| a.nil? ? '*' : a }.join)
    end
  end

  def pwd
    puts '/' + FileSystem::pwd.join('/')
  end

  def mkdir(dir)
    unless FileSystem::create_dir(dir)
      puts "Não é possível criar o diretório '#{dir}'."
    end
  end

  def cd(dir)
    pwd = FileSystem::pwd.clone
    result = case dir
      when "/" then []
      when nil then []
      when ".."
        pwd.pop
        pwd = [] if pwd.empty?
        pwd
      else
        pwd.push(dir.split '/').flatten
    end
    if FileSystem.valid_dir? result
      FileSystem::pwd = result
    else
      puts 'Diretório não existe.'
    end
  end

  def rmdir(dir)
    unless FileSystem::remove_dir(dir)
      puts "Não é possível remover o diretório '#{dir}'."
    end
  end

  def mkfile(file)
    unless FileSystem::create_file(file)
      puts "Não é possível criar o arquivo '#{file}'."
    end
  end

  def rmfile(file)
    unless FileSystem::remove_file(file)
      puts "Não é possível remover o arquivo '#{file}'."
    end
  end

  def chmod(file, permission)
    FileSystem::change_permission(file, permission)
  end

  def run(file)
    if FileSystem::executable_file? file
      FileSystem::execute_file file
    else
      puts "Comando '#{file}' é inválido."
    end
  end

  def ps
    Processes::all
  end

  def kill(id)
    if Processes::kill(id)
      puts "Processo com o id #{id} foi encerrado."
    else
      puts "Não existe um processo com o id #{id}."
    end
  end

  def help
    File.open("#{ROOT}/help.txt", "r") do |f|
      puts f.read
    end
  end

  def exit
    @exit = true
    FileSystem::save
  end

  def exit?
    !@exit.nil?
  end
end
