require_relative '../spec_helper.rb'

RSpec.describe Card do 
  describe "#step" do
    it "" do
      black_mail_type = build(:blackmail_type)
      swamp_type = build(:swamp_type)

      deck = [
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(swamp_type),
        Card.new(swamp_type),
        Card.new(swamp_type),
        Card.new(swamp_type),
      ]
      deck.length.times do |i| 
        deck[i].id = i
      end
      game = Game.new(deck)
      game.step(1)

      play, draw, can, mama = black_mail_type.count(1)
      expect(play).to eq 1;
      expect(draw).to eq 4;
      expect(can).to eq 4;
    end

    it "" do
      black_mail_type = build(:blackmail_type)
      jungle_type = build(:jungle_hollow_type)

      deck = [
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        TapLandCard.new(jungle_type),
        TapLandCard.new(jungle_type),
        TapLandCard.new(jungle_type),
        TapLandCard.new(jungle_type),
      ]
      deck.length.times do |i| 
        deck[i].id = i
      end
      game = Game.new(deck)
      game.step(1)

      play, draw, can, mama = black_mail_type.count(1)
      expect(play).to eq 0;
      expect(draw).to eq 4;
      expect(can).to eq 0;
    end

    it "" do
      black_mail_type = build(:blackmail_type)
      jungle_type = build(:jungle_hollow_type)

      deck = [
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        TapLandCard.new(jungle_type),
        TapLandCard.new(jungle_type),
        TapLandCard.new(jungle_type),
        TapLandCard.new(jungle_type),
      ]
      deck.length.times do |i| 
        deck[i].id = i
      end
      game = Game.new(deck, false)
      game.step(1)
      game.step(2)

      play, draw, can, mama = black_mail_type.count(1)
      expect(play).to eq 0;
      expect(draw).to eq 4;
      expect(can).to eq 0;
      play, draw, can, mama = black_mail_type.count(2)
      expect(play).to eq 1;
      expect(draw).to eq 5;
      expect(can).to eq 5;
    end

    it "" do
      black_mail_type = build(:blackmail_type)
      deathcap_type = build(:deathcap_glade_type)

      deck = [
        SlowLandCard.new(deathcap_type),
        SlowLandCard.new(deathcap_type),
        SlowLandCard.new(deathcap_type),
        SlowLandCard.new(deathcap_type),
        SlowLandCard.new(deathcap_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
        Card.new(black_mail_type),
      ]
      deck.length.times do |i| 
        deck[i].id = i
      end
      game = Game.new(deck)
      game.step(1)
      game.step(2)
      game.step(3)

      play, draw, can, mama = black_mail_type.count(1)
      expect(play).to eq 0;
      play, draw, can, mama = black_mail_type.count(2)
      expect(play).to eq 1;
      play, draw, can, mama = black_mail_type.count(3)
      expect(play).to eq 3;
      expect(can).to eq 4;
    end
  end
end
