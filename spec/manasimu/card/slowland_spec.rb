require_relative '../../spec_helper.rb'

RSpec.describe SlowLandCard do 
  describe "#tapped" do
    context "when any lands are played before," do
      it "should be tapped after resolve" do
        card = build(:deathcap_glade_card)
        card.resolve(nil, [], [])
        expect(card.tapped?).to eq true
      end
    end

    context "when a land is played before," do
      it "should be tapped after resolve" do
        land = build(:swamp)
        card = build(:deathcap_glade_card)
        card.resolve(nil, [], [land])
        expect(card.tapped?).to eq true
      end
    end

    context "when two lands are played before," do
      it "should not be tapped after resolve" do
        lands = [build(:swamp), build(:forest)]
        card = build(:deathcap_glade_card)
        card.resolve(nil, [], lands)
        expect(card.tapped?).to eq false
      end
    end

    context "when tapped slowland are played before," do
      it "should not be tapped after resolve" do
        lands = [build(:swamp)]
        card = build(:deathcap_glade_card)
        card.resolve(nil, [], lands)
        expect(card.tapped?).to eq true
        card.reset
        expect(card.tapped?).to eq false
      end
    end
  end
end
