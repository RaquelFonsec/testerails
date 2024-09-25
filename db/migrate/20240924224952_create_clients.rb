class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :company_id
      t.string :erp
      t.string :erp_key
      t.string :erp_secret
      t.boolean :validated

      t.timestamps
    end
  end
end
