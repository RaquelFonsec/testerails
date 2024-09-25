class CreateClientIntegrations < ActiveRecord::Migration[7.1]
  def change
    create_table :client_integrations do |t|
      t.string :company_id
      t.string :erp
      t.string :erp_key
      t.string :erp_secret

      t.timestamps
    end
  end
end
