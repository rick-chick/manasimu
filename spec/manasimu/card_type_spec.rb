require_relative '../spec_helper.rb'

RSpec.describe CardType do 
  describe "#count" do
    context "when card played" do
      it "should return 0 if a card is not played" do
        card = build(:blackmail)
        played, drawed, can_played, mana_sources = card.card_type.count(1)
        expect(played).to eq 0
      end

      it "should return 1 if a card is played one time" do
        card = build(:blackmail)
        card.played(1)
        played, drawed, can_played , mana_sources = card.card_type.count(1)
        expect(played).to eq 1
      end

      it "should return 2 if two cards are played one time" do
        card_type = build(:blackmail_type)
        card1 = Card.new(card_type)
        card2 = Card.new(card_type)
        card1.played(1)
        card2.played(1)
        played, drawed, can_played, mana_sources  = card_type.count(1)
        expect(played).to eq 2
      end

      it "should return 0 if a card did not check playability" do
        card_type = build(:blackmail_type)
        card1 = Card.new(card_type)
        land = build(:swamp)
        card1.step_in_hands(2)
        played, drawed, can_played, mana_sources  = card_type.count(1)
        expect(can_played).to eq 0
      end

      it "should return 1 if one card is marked playable" do
        card_type = build(:blackmail_type)
        card1 = Card.new(card_type)
        land = build(:swamp)
        card1.playable?([land], ["1"])
        card1.step_in_hands(1)
        played, drawed, can_played, mana_sources  = card_type.count(1)
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
        card1.step_in_hands(1)
        card2.step_in_hands(1)
        played, drawed, can_played, mana_sources  = card_type.count(1)
        expect(can_played).to eq 2
      end

      it "should return 0 if any land are played" do
        card_type = build(:swamp_type)
        played, drawed, can_played, mana_sources  = card_type.count(1)
        expect(mana_sources).to eq({})
      end

      it "should return 1 if one card is step plays" do
        card_type = build(:swamp_type)
        card1 = Card.new(card_type)
        card1.resolve(nil, [], [])
        card1.step_in_plays(1)
        played, drawed, can_played, mana_sources  = card_type.count(1)
        expect(mana_sources["B"]).to eq 1
        expect(mana_sources.keys.length).to eq 1
      end

      it "should return 0 if tapland is step plays" do
        card_type = build(:jungle_hollow_type)
        card1 = TapLandCard.new(card_type)
        card1.resolve(nil, [], [], nil)
        card1.step_in_plays(2)
        played, drawed, can_played, mana_sources  = card_type.count(1)
        expect(mana_sources.keys.length).to eq 0
      end

      it "should return 2 if two color tapland step 2 turn in plays" do
        card_type = build(:jungle_hollow_type)
        card1 = TapLandCard.new(card_type)
        card1.resolve(nil, [], [], nil)
        card1.step_in_plays(1)
        card1.step_in_plays(2)
        played, drawed, can_played, mana_sources  = card_type.count(2)
        expect(mana_sources.keys.length).to eq 2
        expect(mana_sources["B"]).to eq 0.5
        expect(mana_sources["G"]).to eq 0.5
      end
    end
  end
end
