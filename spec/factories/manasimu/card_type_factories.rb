FactoryBot.define do

  initialize_with { new({}) }

  factory :spiritmonger_type, class: CardType do
    contents { [association(:spiritmonger_content)] }
  end

  factory :black_creature_type, class: CardType do
    contents { [association(:black_creature_content)] }
  end

  factory :naturalize_type, class: CardType do
    contents { [association(:naturalize_content)] }
  end

  factory :blackmail_type, class: CardType do
    contents { [association(:blackmail_content)] }
  end

  factory :swamp_type, class: CardType do
    contents { [association(:swamp_content)] }
  end

  factory :forest_type, class: CardType do
    contents { [association(:forest_content)] }
  end

  factory :darkbore_pathway_type, class: CardType do
    contents { [association(:darkbore_pathway_content), association(:slitherbore_pathway_content)] }
  end
end
