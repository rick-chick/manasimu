require_relative '../spec_helper.rb'

RSpec.describe Card do 
  describe "#playable?" do
    it "return false if lands is empty" do
      card = build(:black_creature)
      flg, used, symbols = card.playable?([], [])
      expect(flg).to eq(false)
      expect(used).to eq([])
    end

    it "return true if lands has enough mana" do
      lands = 4.times.to_a.map { build(:swamp) }
      card = build(:black_creature)
      # suppose
      #  lands B B B B
      #  mana_cost B 3
      edges = [
        # source to lands
        [0, 1],
        [0, 2],
        [0, 3],
        [0, 4],
        # mana_cost to destination
        [5, 9],
        [6, 9],
        [7, 9],
        [8, 9],
        # lands to mana_cost
        [1, 5],
        [1, 6],
        [1, 7],
        [1, 8],
        [2, 5],
        [2, 6],
        [2, 7],
        [2, 8],
        [3, 5],
        [3, 6],
        [3, 7],
        [3, 8],
        [4, 5],
        [4, 6],
        [4, 7],
        [4, 8],
      ]
      allow(card).to receive(:edges).and_return([4, 4, edges])
      capas = ["1", "1", "1", "1"]
      flg, used, symbols = card.playable?(lands, capas)
      expect(flg).to eq(true)
      expect(used).to eq([1,1,1,1])
      expect(symbols).to eq(['B', '1','1','1'])
    end

    it "return true if lands has enough mana but no capacity" do
      lands = 4.times.to_a.map { build(:swamp) }
      card = build(:black_creature)
      # suppose
      #  lands B B B B
      #  mana_cost B 3
      edges = [
        # source to lands
        [0, 1],
        [0, 2],
        [0, 3],
        [0, 4],
        # mana_cost to destination
        [5, 9],
        [6, 9],
        [7, 9],
        [8, 9],
        # lands to mana_cost
        [1, 5],
        [1, 6],
        [1, 7],
        [1, 8],
        [2, 5],
        [2, 6],
        [2, 7],
        [2, 8],
        [3, 5],
        [3, 6],
        [3, 7],
        [3, 8],
        [4, 5],
        [4, 6],
        [4, 7],
        [4, 8],
      ]
      allow(card).to receive(:edges).and_return([4, 4, edges])
      capas = ["1", "1", "0", "1"]
      flg, used, symbols = card.playable?(lands, capas)
      expect(flg).to eq(false)
      expect(used).to eq([1,1,1,1])
      expect(symbols).to eq(['1', '1', nil,'1'])
    end

    it "return false if lands dont have enough mana" do
      lands = 3.times.to_a.map { build(:swamp) }
      card = build(:black_creature)
      capas = ["1", "1", "1"]
      # suppose
      #  lands B B B
      #  mana_cost B 3
      edges = [
        # source to lands
        [0, 1],
        [0, 2],
        [0, 3],
        # mana_cost to destination
        [4, 8],
        [5, 8],
        [6, 8],
        [7, 8],
        # lands to mana_cost
        [1, 4],
        [1, 5],
        [1, 6],
        [1, 7],
        [2, 4],
        [2, 5],
        [2, 6],
        [2, 7],
        [3, 4],
        [3, 5],
        [3, 6],
        [3, 7],
      ]
      allow(card).to receive(:edges).and_return([3, 4, edges])
      flg, used, land_symbols  = card.playable?(lands, capas)
      expect(flg).to eq(false)
      expect(used).to eq([])
      expect(land_symbols).to eq([])
    end

    it "return false if lands dont have same symbol mana" do
      lands = 4.times.to_a.map { build(:forest) }
      card = build(:black_creature)
      # suppose
      #  lands B B B
      #  mana_cost B 3
      edges = [
        # source to lands
        [0, 1],
        [0, 2],
        [0, 3],
        [0, 4],
        # mana_cost to destination
        [5, 9],
        [6, 9],
        [7, 9],
        [8, 9],
      ]
      allow(card).to receive(:edges).and_return([4, 4, edges])
      capas = ["1", "1", "1", "1"]
      flg, used, land_symbols  = card.playable?(lands, capas)
      expect(flg).to eq(false)
      expect(used).to eq([1,1,1,0])
      expect(land_symbols).to eq(['1', '1', '1', nil])
    end

    it "return true if there is one mana spell and one land" do
      lands = 1.times.to_a.map { build(:swamp) }
      card = build(:blackmail)
      # suppose
      #  lands B
      #  mana_cost B
      edges = [
        # source to lands
        [0, 1],
        # lands to mana_cost
        [1, 2],
        # mana_cost to destination
        [2, 3]
      ]
      allow(card).to receive(:edges).and_return([1, 1, edges])
      capas = ["1"]
      flg, used, land_symbols  = card.playable?(lands, capas)
      expect(flg).to eq(true)
      expect(used).to eq([1])
      expect(land_symbols).to eq(['B'])
    end

    it "return false if there is one mana spell and one land but no capacity" do
      lands = 1.times.to_a.map { build(:swamp) }
      card = build(:blackmail)
      # suppose
      #  lands B
      #  mana_cost B
      edges = [
        # source to lands
        [0, 1],
        # lands to mana_cost
        [1, 2],
        # mana_cost to destination
        [2, 3]
      ]
      allow(card).to receive(:edges).and_return([1, 1, edges])
      capas = ["0"]
      flg, used, land_symbols  = card.playable?(lands, capas)
      expect(flg).to eq(false)
      expect(used).to eq([0])
      expect(land_symbols).to eq([nil])
    end

  end

  describe "#egdes" do
    context "when land and spell color is match" do
      it "given one swamp and one black mana spell, create connected edge" do
        card = build(:blackmail)
        lands = [build(:swamp)]
        capas = ["1"]
        expect(card.edges(lands, capas)).to eq([
          1, 1,
          [
            [0, 1],
            [1, 2],
            [2, 3],
        ]])
      end

      it "given two swamps and one black mana spell, create connected edge" do
        card = build(:blackmail)
        lands = 2.times.to_a.map {build(:swamp)}
        capas = ["1", "1"]
        expect(card.edges(lands, capas)).to eq([
          2, 1,
          [
            [0, 1],
            [0, 2],
            [1, 3],
            [2, 3],
            [3, 4],
        ]])
      end

      it "given a swamp,forest and one black mana spell, create connected edge" do
        card = build(:blackmail)
        lands = [
          build(:swamp), build(:forest)
        ]
        capas = ["1", "1"]
        expect(card.edges(lands, capas)).to eq([
          2, 1,
          [
            # source -> lands
            [0, 1],
            [0, 2],
            # lands -> mana_cost
            [1, 3],
            # mana_cost -> destination
            [3, 4],
        ]])
      end

      it "given two forest and green mana spell, create connected edge" do
        card = build(:naturalize)
        lands = [build(:forest), build(:forest)]
        capas = ["1", "1"]
        expect(card.edges(lands, capas)).to eq([
          2,2,
          [
            # source -> lands
            [0, 1],
            [0, 2],
            # lands -> mana_cost
            [1, 3],
            [1, 4],
            [2, 3],
            [2, 4],
            # mana_cost -> destination
            [3, 5],
            [4, 5],
        ]])
      end

      it "given swamp,forest and green mana spell, create connected edge" do
        card = build(:naturalize)
        lands = [build(:swamp), build(:forest)]
        capas = ["1", "1"]
        expect(card.edges(lands, capas)).to eq(
            [
            2, 2, [
              # source -> lands
              [0, 1], # swamp
              [0, 2], # forest
              # lands -> mana_cost
              [1, 3], # swamp x 1
              [2, 3], # forest x 1
              [2, 4], # forest x G
              # mana_cost -> destination
              [3, 5], # 1
              [4, 5], # G
            ]])
      end

      it "given swamp,forest and multicolor spell, create connected edge" do
        card = build(:spiritmonger)
        lands = [build(:swamp), build(:forest), build(:forest), build(:forest), build(:forest)]
        capas = ["1", "1", "1", "1", "1"]
        expect(card.edges(lands, capas)).to eq(
        [ 5, 5, 
        [
          # source -> lands
          [0, 1], # swamp
          [0, 2], # forest
          [0, 3], # forest
          [0, 4], # forest
          [0, 5], # forest
          # lands -> mana_cost
          [1, 6], # swamp x 3
          [1, 7], # swamp x 3
          [1, 8], # swamp x 3
          [1, 9], # swamp x B
          [2, 6], # forest x 3
          [2, 7], # forest x 3
          [2, 8], # forest x 3
          [2, 10], # forest x G
          [3, 6], # forest x 3
          [3, 7], # forest x 3
          [3, 8], # forest x 3
          [3, 10], # forest x G
          [4, 6], # forest x 3
          [4, 7], # forest x 3
          [4, 8], # forest x 3
          [4, 10], # forest x G
          [5, 6], # forest x 3
          [5, 7], # forest x 3
          [5, 8], # forest x 3
          [5, 10], # forest x G
          # mana_cost -> destination
          [6, 11], # 3
          [7, 11], # 3
          [8, 11], # 3
          [9, 11], # B
          [10, 11], # G
        ]]
        )
      end
    end
  end

  describe "#can_play?" do
    it "should be false if card step turn" do
      blackmail = build(:blackmail)
      blackmail.step(1)
      expect(blackmail.can_play?).to eq false
    end

    it "should be false if card playable? is false" do
      blackmail_type = build(:blackmail_type)
      allow(blackmail_type)
        .to receive('playable?')
        .and_return [false, [], []]
      blackmail = Card.new(blackmail_type)
      blackmail.step(1)
      blackmail.playable?(nil, nil)
      expect(blackmail.can_play?).to eq false
    end

    it "should be true if card playable? is true" do
      blackmail_type = build(:blackmail_type)
      allow(blackmail_type)
        .to receive('playable?')
        .and_return [true, [], []]
      blackmail = Card.new(blackmail_type)
      blackmail.step(1)
      blackmail.playable?(nil, nil)
      expect(blackmail.can_play?).to eq true
    end

    it "should be false if card playable? is true in some cases" do
      blackmail_type = build(:blackmail_type)
      blackmail = Card.new(blackmail_type)

      blackmail.step(1)

      allow(blackmail_type)
        .to receive('playable?')
        .and_return [false, [], []]
      blackmail.playable?(nil, nil)

      allow(blackmail_type)
        .to receive('playable?')
        .and_return [true, [], []]
      blackmail.playable?(nil, nil)

      allow(blackmail_type)
        .to receive('playable?')
        .and_return [false, [], []]
      blackmail.playable?(nil, nil)

      expect(blackmail.can_play?).to eq true
    end
  end

  describe "#reset" do
    it "should reset played card side" do
      card = build(:black_creature)
      card.played(3, "b")
      expect(card.side).to eq "b"

      card.reset()
      expect(card.side).to eq nil
    end

    it "should reset tapped status" do
      card = build(:black_creature)
      card.played(3, "b")

      card.reset()
      expect(card.tapped?).to eq false
    end
  end
end
