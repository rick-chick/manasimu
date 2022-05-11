class PathwayCard  < Card

  def first_produce_symbol=(symbol)
    if symbol.to_i.to_s == symbol
      @side = 'a'
      @symbol = @card_type.color_identity[0]
    else
      @card_type.color_identity.each_with_index do |ci, i|
        if ci == symbol
          @side = @card_type.contents[i].side
          @symbol = ci
          break
        end
      end
    end
  end

  def color_identity
    if @side
      [@symbol]
    else
      @card_type.color_identity
    end
  end
end
