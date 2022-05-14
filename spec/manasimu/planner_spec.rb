require_relative '../spec_helper.rb'

RSpec.describe Planner do 
  describe "#plan" do
    context "when any spell cant play" do
      it "play land if land in hands" do
        planner = Planner.new
        hands = [build(:swamp), build(:naturalize)]
        fields = []
        expect(planner.plan(hands, fields)).to eq(hands[0..0])
      end
    end

    context "when spell what can play in hands but no land in hands" do
      it "play spell" do
        planner = Planner.new
        hands = [build(:naturalize)]
        fields = [build(:forest), build(:forest)]
        expect(planner.plan(hands, fields)).to eq(hands[0..0])
      end
    end

    context "when tapland is played" do
      it "can't play its turn" do
        planner = Planner.new
        hands = [build(:jungle_hollow_card), build(:blackmail)]
        hands.each do |card|
          card.drawed(1)
        end
        fields = []
        expect(planner.plan(hands, fields)).to eq([hands[0]])
      end

      it "can't play spell " do
        planner = Planner.new
        hands = [build(:blackmail), build(:jungle_hollow_card)]
        fields = []
        expect(planner.plan(hands, fields)).to eq([hands[1]])
      end

      it "can play after step turn" do
        planner = Planner.new
        hands = [build(:blackmail), build(:jungle_hollow_card)]
        fields = []
        expect(planner.plan(hands, fields)).to eq([hands[1]])
        hands.each do |card|
          card.step(2)
        end
        fields = [hands[1]]
        hands = [hands[0]]
        expect(planner.plan(hands, fields)).to eq([hands[0]])
      end
    end

    context "when slowland is played" do
      it "plan can't play spell if there is no land," do
        planner = Planner.new
        hands = [build(:deathcap_glade_card), build(:blackmail)]
        fields = []
        expect(planner.plan(hands, fields)).to eq([hands[0]])
      end

      it "plan can't play spell if there is a land," do
        planner = Planner.new
        hands = [build(:blackmail), build(:deathcap_glade_card)]
        fields = [build(:forest)]
        expect(planner.plan(hands, fields)).to eq([hands[1]])
      end

      it "can play if there is two lands," do
        planner = Planner.new
        hands = [build(:blackmail), build(:deathcap_glade_card)]
        fields = [build(:forest), build(:forest)]
        expect(planner.plan(hands, fields)).to eq(hands.reverse)
      end
    end
  end

  describe "#dfs" do
    context "when a spell,land is provided," do
      it "is expect to be present match if spell was playable" do 
        lands = [build(:swamp)]
        spells = [build(:blackmail)]
        bit_spells = 0
        bit_lands = 0
        price = 0

        planner = Planner.new
        allow(spells[0]).to receive(:playable?).and_return([true, [1], ['B']])

        price, bit_spells, bit_lands, land_symbols = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price, [])

        expect(price).to eq(1)
        expect(bit_spells).to eq (1)
        expect(bit_lands).to eq (1)
        expect(land_symbols).to eq (["B"])
      end

      it "is expect to be present not match if spell was not playable" do 
        lands = [build(:forest), build(:forest)]
        spells = [build(:naturalize)]
        bit_spells = 0
        bit_lands = 0
        price = 0

        planner = Planner.new
        allow(spells[0]).to receive(:playable?).and_return([false, [], []])

        price, bit_spells, bit_lands , land_symbols = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price, [])

        expect(price).to eq(0)
        expect(bit_spells).to eq (0)
        expect(bit_lands).to eq (0)
        expect(land_symbols).to eq ([])
      end
    end

    context "when a spell mana cost is two,and two land are provided," do
      it "is expect to be present match if spell was playable" do 
        lands = [build(:forest), build(:forest)]
        spells = [build(:naturalize)]
        bit_spells = 0
        bit_lands = 0
        price = 0

        planner = Planner.new
        allow(spells[0]).to receive(:playable?).and_return([true, [1,1], ['G', 'G']])

        price, bit_spells, bit_lands, land_symbols  = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price, [])

        expect(price).to eq(2)
        expect(bit_spells).to eq (1)
        expect(bit_lands).to eq (3)
        expect(land_symbols).to eq (['G','G'])
      end
    end

    context "when two playable spell are provided," do
      it "is expect to be present match" do 
        lands = [build(:swamp), build(:swamp)]
        spells = [build(:blackmail), build(:blackmail)]
        bit_spells = 0
        bit_lands = 0
        price = 0

        planner = Planner.new

        price, bit_spells, bit_lands, land_symbols  = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price, [])

        expect(price).to eq(2)
        expect(bit_spells).to eq (3)
        expect(bit_lands).to eq (3)
        expect(land_symbols).to eq (['B', 'B'])
      end
    end
  end

  describe "#bit_select" do
    context "when cards size is 0" do
      it "returns empty if bit is 0" do
        planner = Planner.new
        cards = []
        bit = 0
        result = planner.bit_select(cards, bit)
        expect(result.length).to eq(0)
      end

      it "returns empty if bit is 1" do
        planner = Planner.new
        cards = []
        bit = 1
        result = planner.bit_select(cards, bit)
        expect(result.length).to eq(0)
      end
    end

    context "when cards size is 1" do
      it "returns empty if bit is 0" do
        planner = Planner.new
        cards = [build(:blackmail)]
        bit = 0
        result = planner.bit_select(cards, bit)
        expect(result.length).to eq(0)
      end

      it "returns single element array if bit is 1" do
        planner = Planner.new
        cards = [build(:blackmail)]
        bit = 1
        result = planner.bit_select(cards, bit)
        expect(result.length).to eq(1)
      end
    end

    context "when cards size is 2" do
      it "returns empty if bit is 0" do
        planner = Planner.new
        cards = [build(:blackmail), build(:blackmail)]
        bit = 0
        result = planner.bit_select(cards, bit)
        expect(result.length).to eq(0)
      end

      it "returns single elment array if bit is 2" do
        planner = Planner.new
        cards = [build(:blackmail), build(:blackmail)]
        bit = 2
        result = planner.bit_select(cards, bit)
        expect(result.length).to eq(1)
      end

      it "returns two elments array if bit is 3" do
        planner = Planner.new
        cards = [build(:blackmail), build(:blackmail)]
        bit = 3
        result = planner.bit_select(cards, bit)
        expect(result.length).to eq(2)
      end
    end
  end

  describe "#search_opt_spells" do
    it "" do
      play_land = build(:swamp)
      hands = [ build(:blackmail) ]
      planner = Planner.new
      price, spells, symbols = planner.search_opt_spells(hands, [play_land])
      expect(price).to eq(0)
      expect(spells).to eq([hands[0]])
      expect(symbols).to eq(["B"])
    end

    it "is play two one mana spell" do
      hands = [build(:blackmail), build(:blackmail)]
      planner = Planner.new
      price, spells,symbols = planner.search_opt_spells(hands, [ build(:swamp), build(:swamp) ])
      expect(spells[0]).to eq(hands[0])
      expect(spells[1]).to eq(hands[1])
      expect(symbols).to eq(["B", "B"])
    end

    it "" do
      hands = [build(:blackmail)]
      planner = Planner.new
      price, spells ,symbols = planner.search_opt_spells(hands, [build(:forest)])
      expect(price).to eq(0)
      expect(spells).to eq([])
      expect(symbols).to eq([])
    end
  end

  describe "#plan" do
    it "" do
      hands = [ build(:swamp), build(:blackmail) ]
      planner = Planner.new
      drops = planner.plan(hands, [])
      expect(drops).to eq(hands)
    end

    it "" do
      hands = [ build(:forest), build(:blackmail) ]
      planner = Planner.new
      drops = planner.plan(hands, [])
      expect(drops).to eq([hands[0]])
    end

    it "" do
      hands = [ build(:swamp), build(:forest), build(:blackmail) ]
      planner = Planner.new
      drops = planner.plan(hands, [])
      expect(drops[0]).to eq(hands[0])
      expect(drops[1]).to eq(hands[2])
    end

    it "" do
      hands = [ build(:swamp), build(:blackmail), build(:blackmail) ]
      planner = Planner.new
      drops = planner.plan(hands, [build(:swamp)])
      expect(drops[0]).to eq(hands[0])
      expect(drops[1]).to eq(hands[1])
      expect(drops[2]).to eq(hands[2])
    end

    it "" do
      hands = [ build(:swamp), build(:blackmail), build(:black_creature) ]
      planner = Planner.new
      drops = planner.plan(hands, [build(:swamp)])
      expect(drops[0]).to eq(hands[0])
      expect(drops[1]).to eq(hands[1])
      expect(drops[2]).to eq(nil)
    end

    it "" do
      hands = [ build(:forest), build(:blackmail), build(:naturalize) ]
      planner = Planner.new
      drops = planner.plan(hands, [build(:swamp)])
      expect(drops[0]).to eq(hands[0])
      expect(drops[1]).to eq(hands[2])
    end
  end

end
