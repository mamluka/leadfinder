require_relative '../../api/core/orm'

email = ARGV[0]
plan = ARGV[1]

user = User.new(
    email: email,
    plan: plan
)
user.upsert