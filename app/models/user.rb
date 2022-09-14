require "validator/email_validator"

class User < ApplicationRecord
  before_validation :downcase_email

  # gem bcryptを追加で使用可能なパスワード暗号化する機能
  #暗号化パスワードはpassword_digestというカラムに保存される為、作成しておく必要がある
  has_secure_password

#バリデーション
  validates :name, presence: true, length: { maximum: 30, allow_blank: true}
  validates :email, presence: true, email: { allow_blank: true }
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password,
            presence: true,
            length: { minimum: 8 },
            format: {with: VALID_PASSWORD_REGEX, message: :invalid_password},
            allow_nil: true

  class << self
    # emailからアクティブなユーザーを返す
    def find_activated(email)
      find_by(email: email, activated: true)
    end
  end
  # 自分以外の同じemailのアクティブなユーザーがいる場合にtrueを返す
  def email_activated?
    users = User.where.not(id: id)
    users.find_activated(email).present?
  end

  private
  #メールアドレスを小文字化
  def downcase_email
    self.email.downcase! if email
  end

end
