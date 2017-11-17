module Erp
  module Consignments
    module Backend
      class ConsignmentDetailsController < Erp::Backend::BackendController
        def consignment_detail_line_form
          @consignment_detail = ConsignmentDetail.new
          @consignment_detail.product_id = params[:add_value]

          @consignment_detail.state = Erp::Products::State.first

          render partial: params[:partial], locals: {
            consignment_detail: @consignment_detail,
            uid: helpers.unique_id()
          }
        end
      end
    end
  end
end
