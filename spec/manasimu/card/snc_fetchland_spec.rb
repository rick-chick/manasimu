require_relative '../../spec_helper.rb'

RSpec.describe SncFetchLandCard do 
  describe "#mana_source" do

    let(:land) {
      land = build(:obscura_storefront_card)
      land.configure
    }

    context "when it is resolved," do
      it "should produces color from basic land card amoung given deck which contains only a island" do
        hands = []
        plays = []
        deck = [build(:island)]
        land.resolve(nil, hands, plays, deck)
        expect(land.mana_source).to eq ["U"]
      end

      it "should produces color from basic land card amoung given deck which contains island and swamp" do
        hands = []
        plays = []
        deck = [build(:island), build(:swamp)]
        land.resolve(nil, hands, plays, deck)
        expect(land.mana_source).to eq ["U", "B"]
      end

      it "should produces blank if deck does not have any land" do
        hands = []
        plays = []
        deck = [build(:blackmail)]
        land.resolve(nil, hands, plays, deck)
        expect(land.mana_source).to eq []
      end

      it "should produces blank if deck is nil" do
        hands = []
        plays = []
        deck = nil
        land.resolve(nil, hands, plays, deck)
        expect(land.mana_source).to eq []
      end

      it "should not be produces out of colors" do
        hands = []
        plays = []
        deck = [build(:forest)]
        land.resolve(nil, hands, plays, deck)
        expect(land.mana_source).to eq []
      end
    end

    context "when it is first_produce_symbols," do
      it "should produces the only color that was first_produce_symbol" do
        hands = []
        plays = []
        deck = [build(:island)]
        land.resolve(nil, hands, plays, deck)
        land.first_produce_symbol = "U"
        expect(land.mana_source).to eq ["U"]
      end

      it "should delete a basic land card from deck" do
        hands = []
        plays = []
        deck = [build(:island)]
        land.resolve(nil, hands, plays, deck)
        land.first_produce_symbol = "U"
        expect(deck).to eq []
      end

      it "should delete a basic land card from deck when there are two lands in deck" do
        hands = []
        plays = []
        deck = [build(:island), build(:island)]
        land.resolve(nil, hands, plays, deck)
        land.first_produce_symbol = "U"
        expect(deck.length).to eq 1
      end

      it "should delete a basic land card from deck when there are two lands in deck" do
        hands = []
        plays = []
        deck = [build(:swamp), build(:island)]
        land.configure
        land.resolve(nil, hands, plays, deck)
        land.first_produce_symbol = "U"
        expect(deck.length).to eq 1
        expect(deck[0].mana_source).to eq ["U"]
      end
    end

    context "when reset" do
      it "should be initialize mana_source and to be raise error" do
        hands = []
        plays = []
        deck = [build(:swamp), build(:forest)]
        land.resolve(nil, hands, plays, deck)
        expect(land.mana_source).to eq ['B']
        land.reset
        expect{land.mana_source}.to raise_error
      end
    end
  end

  describe "#tapped" do
    let(:land) {
      land = build(:obscura_storefront_card)
      land.configure
    }
    it "should be tapped when enter the battle field" do
      hands = []
      plays = []
      deck = [build(:swamp), build(:island)]
      land.resolve(nil, hands, plays, deck)
      expect(land.tapped?).to eq true
    end

    it "should not be tapped after step_in_plays" do
      hands = []
      plays = []
      deck = [build(:swamp), build(:island)]
      land.resolve(nil, hands, plays, deck)
      expect(land.tapped?).to eq true
      land.step_in_plays(1)
      expect(land.tapped?).to eq false
    end
  end

  describe "#reset" do
    let(:land) {
      land = build(:obscura_storefront_card)
      land.configure
    }
    it "should be tapped if tapped" do
      hands = []
      plays = []
      deck = [build(:swamp), build(:island)]
      land.resolve(nil, hands, plays, deck)
      expect(land.tapped?).to eq true
      land.reset
      expect(land.tapped?).to eq false
    end
  end
end
