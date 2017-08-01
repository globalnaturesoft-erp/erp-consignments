class CreateErpConsignmentsConsignmentDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_consignments_consignment_details do |t|
      t.integer :quantity, default: 1
      t.references :product, index: true, references: :erp_products_products
      t.references :consignment, index: true, references: :erp_consignments_consignments
      t.references :warehouse, index: true, references: :erp_warehouses_warehouses

      t.timestamps
    end
  end
end
