module Erp::Consignments
  class ConsignmentDetail < ApplicationRecord
    validates :consignment, :quantity, presence: true
    belongs_to :consignment, inverse_of: :consignment_details  
    has_many :return_details, class_name: "Erp::Consignments::ReturnDetail"
    
    if Erp::Core.available?("products")
      validates :product_id, presence: true
      belongs_to :product, class_name: "Erp::Products::Product"
      
      def returned_amount
        self.return_details.joins(:delivery)
                            .where(erp_deliveries_deliveries: {delivery_type: Erp::Deliveries::Delivery::TYPE_IMPORT})
                            .sum('erp_deliveries_delivery_details.quantity')
      end
      
      def returned_quantity        
        self.return_details.sum('erp_consignments_return_details.quantity')
      end
      
      def remain_quantity        
        quantity - returned_quantity
      end
      
      def get_product_code
        product.code
      end
      
      def get_product_name
        product.name
      end
      
      def get_product_unit
				product.unit.present? ? product.unit.name : ''        
      end
    end
  end
end
