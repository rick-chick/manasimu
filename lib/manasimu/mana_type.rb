class ManaType
  attr_accessor :color, :land_type

  def initialize(color, land_type)
    @land_type = land_type
    @color = color
  end

  def self.all
    r ||= Red.new
    u ||= Blue.new
    g ||= Green.new
    w ||= White.new
    b ||= Black.new
    @@all ||= [r, u, g, w, b]
  end

  def self.search_text_by_land_type(text)
    self.all.select do |mana_type|
      text.include? mana_type.land_type
    end
  end

  def self.search_text_by_color(text)
    self.all.select do |mana_type|
      text.include? mana_type.color
    end
  end

  class Red < ManaType
    def initialize
      super("R", "Mountain")
    end
  end
  class Blue < ManaType
    def initialize
      super("U", "Island")
    end
  end
  class Green < ManaType
    def initialize
      super("G", "Forest")
    end
  end
  class White < ManaType
    def initialize
      super("W", "Plains")
    end
  end
  class Black < ManaType
    def initialize
      super("B", "Swamp")
    end
  end
end
