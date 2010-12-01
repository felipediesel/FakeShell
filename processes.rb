class Processes
  @@processes = {}

  def self.load(file)
    id = (@@processes.keys.sort.last || -1) + 1
    @@processes[id] = file
  end

  def self.kill(id)
    @@processes.delete id.to_i
  end

  def self.executing?(file)
    @@processes.has_value? file
  end

  def self.all
    @@processes.each do |id, file|
      puts "#{id.to_s.ljust 4} #{file[file.length-1]}"
    end
  end

end
