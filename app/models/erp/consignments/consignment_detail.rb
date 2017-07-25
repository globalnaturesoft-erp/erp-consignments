module Erp::Consignments
  class ConsignmentDetail < ApplicationRecord
    validates :consignment, :quantity, presence: true
    
    if Erp::Core.available?("products")
      validates :product_id, presence: true
      belongs_to :product, class_name: "Erp::Products::Product"      
      def get_product_code
        product.code
      end
      
      def get_product_name
        product.name
      end
      
      def get_product_unit
        product.unit.name
      end
    end
    belongs_to :consignment, inverse_of: :consignment_details    
  end
end
