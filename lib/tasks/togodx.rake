namespace :togodx do
  desc "Add index for awesome_nested_set to all classification tables"
  task rebuild: :environment do
    [1, 2, 3, 4, 5].each do |i|
      Classification.select_table(i)
      Classification.rebuild!
    end
  end
end
