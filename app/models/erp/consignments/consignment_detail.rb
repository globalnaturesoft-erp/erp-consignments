module Erp::Consignments
  class ConsignmentDetail < ApplicationRecord
    validates :consignment, :quantity, presence: true
    belongs_to :consignment, inverse_of: :consignment_details  
    has_many :return_details, class_name: "Erp::Consignments::ReturnDetail"
    belongs_to :state, class_name: "Erp::Products::State"
    
    if Erp::Core.available?("products")
      validates :product_id, presence: true
      belongs_to :product, class_name: "Erp::Products::Product"
      
      def returned_amount
        self.return_details.joins(:delivery)
            .where(erp_deliveries_deliveries: {delivery_type: Erp::Deliveries::Delivery::TYPE_IMPORT})
            .sum('erp_deliveries_delivery_details.quantity')
      end
      
      def returned_quantity        
        self.return_details.includes(:cs_return)
            .where(erp_consignments_cs_returns: {status: Erp::Consignments::CsReturn::STATUS_DELIVERED})
            .sum('erp_consignments_return_details.quantity')
      end
      
      def remain_quantity        
        quantity - returned_quantity
      end
      
      def get_product_code
				product.present? ? product.code : ''
      end
      
      def get_product_name
				product.present? ? product.name : ''
      end
      
      def get_product_unit
				product.unit.present? ? product.unit.name : ''        
      end
    
			def state_name
				state.nil? ? '' : state.name
			end

      def return_status
        remain_quantity == 0 ? 'Hàng trả xong' : 'Chưa trả xong'
      end
    end
  end
end
