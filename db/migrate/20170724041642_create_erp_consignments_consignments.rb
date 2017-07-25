class CreateErpConsignmentsConsignments < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_consignments_consignments do |t|
      t.string :code
      t.datetime :sent_date
      t.datetime :return_date
      t.string :consignment_type
      t.text :note
      t.string :status, default: "pending"
      t.boolean :archived, default: false
      t.references :contact, index: true, references: :erp_contacts_contacts
      t.references :warehouse, index: true, references: :erp_warehouses_warehouses
      t.references :employee, index: true, references: :erp_users
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end
