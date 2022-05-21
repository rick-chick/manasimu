require_relative '../../spec_helper.rb'

RSpec.describe SncFetchLandCard do 
  describe "#color_identiy" do
  end

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
  end
end
