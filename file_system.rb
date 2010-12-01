class FileSystem
  @@files = {}

# {'dir1' => {'dir2' => ['file', ['r', 'x']]}}

  def self.load
    @@files = if File.exists? "#{ROOT}/files.yml"
      YAML::load(File.open("#{ROOT}/files.yml"))
    else
      {}
    end
  end

  def self.save
    File.open("#{ROOT}/files.yml", "w") do |f|
      f.write @@files.to_yaml
    end
  end

  def self.create_dir(dir)
    write(dir, {})
  end

  def self.remove_dir(dir)
    if valid_dir?((pwd + [dir.split('/')]).flatten) and current_dir[dir].empty?
      current_dir.delete(dir)
    end
  end

  def self.create_file(file)
    write(file, [nil, nil])
  end

  def self.remove_file(file)
    if file?(file) and !Processes::executing?(pwd + [file]) and current_dir[file][0].nil?
      current_dir.delete(file)
    end
  end

  def self.write(key, content)
    files = self.current_dir
    if files[key].nil?
      files[key] = content
      true
    else
      false
    end
  end

  def self.change_permission(file, permission)
    if file? file
      case permission
        when '+r' then current_dir[file][0] = 'r'
        when '-r' then current_dir[file][0] = nil
        when '+x' then current_dir[file][1] = 'x'
        when '-x' then current_dir[file][1] = nil
      end
      true
    else
      false
    end
  end

  def self.pwd
    @@pwd ||= []
  end

  def self.pwd=(dir)
    @@pwd = dir if valid_dir?(dir)
  end

  def self.valid_dir?(dir)
    dirs = @@files
    dir.each do |pos|
      return false if dirs[pos].nil?
      dirs = dirs[pos]
    end
    return dirs.is_a?(Hash)
  end

  def self.execute_file(file)
    if executable_file?(file)
      Processes::load(FileSystem::pwd + [file])
    end
  end

  def self.file?(file)
    !current_dir[file].nil? and current_dir[file].is_a?(Array)
  end

  def self.executable_file?(file)
    file?(file) and  !current_dir[file][1].nil?
  end

  def self.current_dir
    dir = @@files
    pwd.each do |pos|
      dir = dir[pos]
    end
    dir
  end

  def self.files
    @@files
  end
end
