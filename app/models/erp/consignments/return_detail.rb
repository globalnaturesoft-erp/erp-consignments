module Erp::Consignments
  class ReturnDetail < ApplicationRecord
    belongs_to :cs_return, inverse_of: :return_details
    validates :cs_return, presence: true
    belongs_to :consignment_detail, class_name: "Erp::Consignments::ConsignmentDetail"
    
    STATUS_RETURNED = 'returned'
    STATUS_NOT_RETURN = 'not_return'
    STATUS_OVER_RETURED = 'over_returned'
    
    def get_remain_quantity
      consignment_detail.remain_quantity
    end
    
    def get_consignment_quantity
      consignment_detail.quantity
    end
    
    def get_returned_quantity
      consignment_detail.returned_quantity
    end
    
    def get_consignment_code
      consignment_detail.consignment.code
    end
    
    def get_product_code
      consignment_detail.get_product_code
    end
    
    def get_product_name
      consignment_detail.get_product_name
    end
  
    def get_product_unit
      consignment_detail.get_product_unit
    end
      
  end
end
