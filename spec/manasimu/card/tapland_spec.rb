require_relative '../../spec_helper.rb'

RSpec.describe TapLandCard do 
  describe "#played" do
    it "should be tapped if it resolve" do
      card = build(:jungle_hollow_card)
      card.resolve(nil, nil, nil)
      expect(card.tapped?).to eq true
    end

    it "should be untapped if step turn" do
      card = build(:jungle_hollow_card)
      card.resolve(nil, nil, nil)
      card.step(2)
      expect(card.tapped?).to eq false
    end
  end
end
