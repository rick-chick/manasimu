FactoryBot.define do

  initialize_with { new({}) }

  factory :spiritmonger, class: Card do
    card_type { association(:spiritmonger_type)}
  end

  factory :black_creature, class: Card do
    card_type { association(:black_creature_type) }
  end

  factory :naturalize, class: Card do
    card_type { association(:naturalize_type) }
  end

  factory :blackmail, class: Card do
    card_type { association(:blackmail_type) }
  end

  factory :swamp, class: Card do
    card_type { association(:swamp_type) }
  end

  factory :forest, class: Card do
    card_type { association(:forest_type) }
  end
end
