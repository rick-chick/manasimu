class Expansion
  attr_accessor :code, :name, :exists

  def self.load
    return [] if not File.exists?(File.expand_path( '../../../db/expansions', __FILE__ ))
    File.open(File.expand_path( '../../../db/expansions', __FILE__ ), "r") do |file|
      Marshal.load(file)
    end
  end

  def ==(other)
    self.code == other.code and self.exists
  end
end
