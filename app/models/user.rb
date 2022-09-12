class User < ApplicationRecord
  # gem bcryptを追加で使用可能なパスワード暗号化する機能
  #暗号化パスワードはpassword_digestというカラムに保存される為、作成しておく必要がある
  has_secure_password

 #バリデーション
  validates :name, presence: true,length: { maximum: 30, allow_blank: true}
  user.errors.add(:name, :too_long, count: 30)
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password,
            presence: true,
            length: { minimum: 8 },
            format: {with: VALID_PASSWORD_REGEX,message: :invalid_password},
            allow_nil: true
end
