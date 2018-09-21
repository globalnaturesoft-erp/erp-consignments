class AddConfirmedAtToErpConsignmentsCsReturns < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_consignments_cs_returns, :confirmed_at, :datetime
  end
end
