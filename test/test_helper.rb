ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# gem 'minitest-reporters' セットアップ
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase

  #seed.rbを読み込みテスト環境でもseedデータを使用可にする
  parallelize_setup do |worker|
    load "#{Rails.root}/db/seeds.rb"
  end

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  #ユーザーテーブルからアクティブなユーザーを一人取り出す
  def active_user
    User.find_by(activated: true)
  end

end
