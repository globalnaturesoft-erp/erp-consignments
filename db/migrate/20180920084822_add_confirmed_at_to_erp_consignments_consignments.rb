class AddConfirmedAtToErpConsignmentsConsignments < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_consignments_consignments, :confirmed_at, :datetime
  end
end
