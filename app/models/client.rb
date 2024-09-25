class Client < ApplicationRecord
    validates :company_id, presence: true
    validates :erp_key, presence: true
    validates :erp_secret, presence: true
  end
  