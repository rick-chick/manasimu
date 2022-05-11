require_relative '../../spec_helper.rb'

RSpec.describe PathwayCard do 
  describe "#reset" do
    it "reset propety side and color_identity" do
      land = build(:darkbore_pathway_card)
      land.first_produce_symbol = 'B'
      land.reset
      expect(land.side).to eq nil
      expect(land.color_identity).to eq ["B", "G"]
    end
  end

  describe "#first_produce_symbol" do
    it "is B then it is set side 'a' and color_identity to be B" do
      land = build(:darkbore_pathway_card)
      expect(land.color_identity).to eq ["B", "G"]
      land.first_produce_symbol = 'B'
      expect(land.side).to eq 'a'
      expect(land.color_identity).to eq ['B']
    end

    it "is G then it is set side 'b' and color_identity to be G" do
      land = build(:darkbore_pathway_card)
      land.first_produce_symbol = 'G'
      expect(land.side).to eq 'b'
      expect(land.color_identity).to eq ['G']
    end

    it "is 1 then it is set side 'a' and color_identity to be B" do
      land = build(:darkbore_pathway_card)
      land.first_produce_symbol = '1'
      expect(land.side).to eq 'a'
      expect(land.color_identity).to eq ['B']
    end
  end
end
