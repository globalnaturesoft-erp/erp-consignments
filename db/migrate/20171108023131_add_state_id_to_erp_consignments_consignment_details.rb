class AddStateIdToErpConsignmentsConsignmentDetails < ActiveRecord::Migration[5.1]
  def change
    add_reference :erp_consignments_consignment_details, :state, index: true, references: :erp_products_states
  end
end
