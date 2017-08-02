class CreateErpConsignmentsCsReturns < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_consignments_cs_returns do |t|
      t.string :code
      t.datetime :return_date
      t.text :note
      t.string :status, default: "draft"
      t.boolean :archived, default: false
      t.references :warehouse, index: true, references: :erp_warehouses_warehouses
      t.references :consignment, index: true, references: :erp_consignments_consignments
      t.references :contact, index: true, references: :erp_contacts_contacts
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end
