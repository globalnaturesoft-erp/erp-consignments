class CreateErpConsignmentsReturnDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_consignments_return_details do |t|
      t.integer :quantity, dedault: 1
      t.references :warehouse, index: true, references: :erp_warehouses_warehouses
      t.references :cs_return, index: true, references: :erp_consignments_cs_returns
      t.references :consignment_detail, index: true, references: :erp_consignments_consignment_details

      t.timestamps
    end
  end
end
