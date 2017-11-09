class AddStateIdToErpConsignmentsReturnDetails < ActiveRecord::Migration[5.1]
  def change
    add_reference :erp_consignments_return_details, :state, index: true, references: :erp_products_states
  end
end
