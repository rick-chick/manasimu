require_relative '../spec_helper.rb'

RSpec.describe CardType do 
  describe "#count" do
    context "when card played" do
      it "should return 0 if a card is not played" do
        card = build(:blackmail)
        played, drawed, can_played = card.card_type.count(1)
        expect(played).to eq 0
      end

      it "should return 1 if a card is played one time" do
        card = build(:blackmail)
        card.played(1)
        played, drawed, can_played = card.card_type.count(1)
        expect(played).to eq 1
      end

      it "should return 2 if two cards are played one time" do
        card_type = build(:blackmail_type)
        card1 = Card.new(card_type)
        card2 = Card.new(card_type)
        card1.played(1)
        card2.played(1)
        played, drawed, can_played = card_type.count(1)
        expect(played).to eq 2
      end

      it "should return 0 if a card did not check playability" do
        card_type = build(:blackmail_type)
        card1 = Card.new(card_type)
        land = build(:swamp)
        card1.step(2)
        played, drawed, can_played = card_type.count(1)
        expect(can_played).to eq 0
      end

      it "should return 1 if one card is marked playable" do
        card_type = build(:blackmail_type)
        card1 = Card.new(card_type)
        land = build(:swamp)
        card1.playable?([land], ["1"])
        card1.step(2)
        played, drawed, can_played = card_type.count(1)
        expect(can_played).to eq 1
      end

      it "should return two if two cards are marked playable" do
        card_type = build(:blackmail_type)
        card1 = Card.new(card_type)
        card2 = Card.new(card_type)
        card1.played(1)
        card2.played(1)
        land = build(:swamp)
        card1.playable?([land], ["1"])
        card2.playable?([land], ["1"])
        card1.step(2)
        card2.step(2)
        played, drawed, can_played = card_type.count(1)
        expect(can_played).to eq 2
      end
    end
  end
end
