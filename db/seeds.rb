# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

Timecop.safe_mode = true

today = Date.today

user1 = User.create!(email: 'bob@example.com', password: '123456')
user2 = User.create!(email: 'chris@example.com', password: '123456')

whodunnit1 = user1.id.to_s
whodunnit2 = user2.id.to_s

project1 = Project.new(
  state: 1,
  status: 1,
  name: 'Project #1',
  description: 'My description 1',
  baseline: 1000,
  savings: 100,
  start_on: Date.new(2019, 1, 1),
  end_on: Date.new(2019, 12, 31)
)

project2 = Project.new(
  state: 1,
  status: 1,
  name: 'Project #2',
  description: 'My description 2',
  baseline: 250,
  savings: 0,
  start_on: Date.new(2019, 1, 1),
  end_on: Date.new(2019, 12, 31)
)

project3 = Project.new(
  state: 1,
  status: 1,
  name: 'Project #3',
  description: 'My description 3',
  baseline: 1000,
  savings: 100,
  start_on: Date.new(2019, 1, 1),
  end_on: Date.new(2019, 12, 31)
)

project4 = Project.new(
  state: 1,
  status: 1,
  name: 'Project #4',
  description: 'My description 4',
  baseline: 500,
  savings: 10,
  start_on: Date.new(2019, 1, 1),
  end_on: Date.new(2019, 12, 31)
)

project5 = Project.new(
  state: 1,
  status: 1,
  name: 'Project #5',
  description: 'My description 5',
  baseline: 850,
  savings: 90,
  start_on: Date.new(2019, 1, 1),
  end_on: Date.new(2019, 12, 31)
)

project6 = Project.new(
  state: 1,
  status: 1,
  name: 'Project #6',
  description: 'My description 6',
  baseline: 1010,
  savings: 150,
  start_on: Date.new(2019, 1, 1),
  end_on: Date.new(2019, 12, 31)
)

negotiation1 = Negotiation.new(
  project: project3,
  state: 1,
  name: 'Negotiation #1',
  baseline: 900,
  savings: 90
)

negotiation2 = Negotiation.new(
  project: project2,
  state: 2,
  name: 'Negotiation #2',
  baseline: 245,
  savings: 10
)

PaperTrail.request.whodunnit = whodunnit1

Timecop.freeze(today - 30) do
  project1.save!
  project5.save!
end

Timecop.freeze(today - 25) do
  project2.save!
end

Timecop.freeze(today - 21) do
  project3.save!
end

PaperTrail.request.whodunnit = whodunnit2

Timecop.freeze(today - 18) do
  project4.save!
end

Timecop.freeze(today - 17) do
  project2.update!(state: 2, baseline: 275, savings: 55)
end

Timecop.freeze(today - 16) do
  project5.destroy!
end

Timecop.freeze(today - 12) do
  project6.save!
end

PaperTrail.request.whodunnit = whodunnit1

Timecop.freeze(today - 11) do
  negotiation1.save!
end

Timecop.freeze(today - 10) do
  negotiation1.update!(state: 2)
  project3.update!(state: 2, status: 2, description: 'My updated description')
end

PaperTrail.request.whodunnit = whodunnit2

Timecop.freeze(today - 7) do
  project4.destroy!
end

Timecop.freeze(today - 3) do
  negotiation2.save!
end

Timecop.freeze(today - 3) do
  negotiation2.update!(savings: 12)
end
