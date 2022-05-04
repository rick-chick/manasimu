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
        allow(spells[0]).to receive(:playable?).and_return([true, [1]])

        price, bit_spells, bit_lands = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price)

        expect(price).to eq(1)
        expect(bit_spells).to eq (1)
        expect(bit_lands).to eq (1)
      end

      it "is expect to be present not match if spell was not playable" do 
        lands = [build(:forest), build(:forest)]
        spells = [build(:naturalize)]
        bit_spells = 0
        bit_lands = 0
        price = 0

        planner = Planner.new
        allow(spells[0]).to receive(:playable?).and_return([false, []])

        price, bit_spells, bit_lands = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price)

        expect(price).to eq(0)
        expect(bit_spells).to eq (0)
        expect(bit_lands).to eq (0)
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
        allow(spells[0]).to receive(:playable?).and_return([true, [1,1]])

        price, bit_spells, bit_lands = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price)

        expect(price).to eq(2)
        expect(bit_spells).to eq (1)
        expect(bit_lands).to eq (3)
      end
    end

    context "when a two playable spell are provided," do
      it "is expect to be present match" do 
        lands = [build(:swamp), build(:swamp)]
        spells = [build(:blackmail), build(:blackmail)]
        bit_spells = 0
        bit_lands = 0
        price = 0

        planner = Planner.new
        allow(spells[0]).to receive(:playable?).and_return([true, [1]])
        allow(spells[1]).to receive(:playable?).and_return([true, [1]])

        price, bit_spells, bit_lands = 
          planner.dfs(1, spells, lands, bit_spells, bit_lands, price)

        expect(price).to eq(2)
        expect(bit_spells).to eq (3)
        expect(bit_lands).to eq (3)
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

  describe "#update_bit" do
    
    it "when one land is used,update bit to 1" do
      used_lands = [1]
      bit_lands = 0

      planner = Planner.new
      result = planner.update_bit(used_lands, bit_lands)

      expect(result).to eq(1)
    end

    it "when one land is not used,dont update bit " do
      used_lands = [0]
      bit_lands = 0

      planner = Planner.new
      result = planner.update_bit(used_lands, bit_lands)

      expect(result).to eq(0)
    end

    it "when one land is not used,dont update bit " do
      used_lands = [0]
      bit_lands = 1

      planner = Planner.new
      result = planner.update_bit(used_lands, bit_lands)

      expect(result).to eq(1)
    end

    it "when two lands are used,update bit to 3" do
      used_lands = [1, 1]
      bit_lands = 0

      planner = Planner.new
      result = planner.update_bit(used_lands, bit_lands)

      expect(result).to eq(3)
    end

    it "when one of two land are used,update bit" do
      used_lands = [0, 1]
      bit_lands = 0

      planner = Planner.new
      result = planner.update_bit(used_lands, bit_lands)

      expect(result).to eq(2)
    end

    it "when one of two land are used,update bit" do
      used_lands = [1, 0]
      bit_lands = 0

      planner = Planner.new
      result = planner.update_bit(used_lands, bit_lands)

      expect(result).to eq(1)
    end

    it "when one of two land are used,update bit" do
      used_lands = [0, 1]
      bit_lands = 1

      planner = Planner.new
      result = planner.update_bit(used_lands, bit_lands)

      expect(result).to eq(3)
    end
  end

  describe "#search_opt_spells" do
    it "" do
      play_land = build(:swamp)
      hands = [ build(:blackmail) ]
      planner = Planner.new
      price, spells = planner.search_opt_spells(hands, [play_land])
      expect(price).to eq(0)
      expect(spells).to eq([hands[0]])
    end

    it "is play two one mana spell" do
      hands = [build(:blackmail), build(:blackmail)]
      planner = Planner.new
      price, spells = planner.search_opt_spells(hands, [ build(:swamp), build(:swamp) ])
      expect(spells[0]).to eq(hands[0])
      expect(spells[1]).to eq(hands[1])
    end

    it "" do
      hands = [build(:blackmail)]
      planner = Planner.new
      price, spells = planner.search_opt_spells(hands, [build(:forest)])
      expect(price).to eq(0)
      expect(spells).to eq([])
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

  describe "#reverse_bit" do
    it "" do
      planner = Planner.new
      expect(planner.reverse_bit(0, 1)).to eq(1)
    end

    it "" do
      planner = Planner.new
      expect(planner.reverse_bit(0, 0)).to eq(0)
    end

    it "" do
      planner = Planner.new
      expect(planner.reverse_bit(3, 2)).to eq(0)
    end
    
    it "" do
      planner = Planner.new
      expect(planner.reverse_bit(0, 2)).to eq(3)
    end
  end

end
