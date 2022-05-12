require_relative '../../spec_helper.rb'

RSpec.describe TapLandCard do 
  describe "#played" do
    it "should be tapped if played" do
      card = build(:jungle_hollow_card)
      card.played(1)
      expect(card.tapped?).to eq true
    end

    it "should be untapped if step turn" do
      card = build(:jungle_hollow_card)
      card.played(1)
      card.step(2)
      expect(card.tapped?).to eq false
    end
  end
end
