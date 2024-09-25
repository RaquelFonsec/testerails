class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :client, null: false, foreign_key: true
      t.string :payment_id
      t.string :status
      t.datetime :payment_date

      t.timestamps
    end
  end
end
