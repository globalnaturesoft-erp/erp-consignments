class AddCacheSearchToErpConsignmentsConsignments < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_consignments_consignments, :cache_search, :text
  end
end
