module Erp
  module Consignments
    module Backend
      class CsReturnsController < Erp::Backend::BackendController
        before_action :set_cs_return, only: [:archive, :unarchive, :set_draft, :set_active, :set_delivered, :set_deleted,
                                             :show, :show_list, :pdf, :edit, :update]
        before_action :set_cs_returns, only: [:delete_all, :archive_all, :unarchive_all, :set_draft_all, :set_active_all, :set_delivered_all, :set_deleted_all]
    
        # GET /cs_returns
        def index
          if Erp::Core.available?("ortho_k")
            authorize! :sales_cs_returns_index, nil
          end
        end
    
        # POST /cs_returns/list
        def list
          if Erp::Core.available?("ortho_k")
            authorize! :sales_cs_returns_index, nil
          end
          
          @cs_returns = CsReturn.search(params).paginate(:page => params[:page], :per_page => 10)
          
          if params.to_unsafe_hash[:global_filter].present? and params.to_unsafe_hash[:global_filter][:return_from_date].present?
            @cs_returns = @cs_returns.where('return_date >= ?', params.to_unsafe_hash[:global_filter][:return_from_date].to_date.beginning_of_day)
          end

          if params.to_unsafe_hash[:global_filter].present? and params.to_unsafe_hash[:global_filter][:return_to_date].present? 
            @cs_returns = @cs_returns.where('return_date <= ?', params.to_unsafe_hash[:global_filter][:return_to_date].to_date.end_of_day)
          end
          
          render layout: nil
        end
        
        def return_details
          @cs_return = CsReturn.find(params[:id])
          
          render layout: nil
        end
        
        # GET /cs_returns/1
        def show
          authorize! :print, @cs_return
          
          respond_to do |format|
            format.html
            format.pdf do
              render pdf: "show_list",
                layout: 'erp/backend/pdf'
            end
          end
        end

        # POST /cs_returns/list
        def show_list
        end

        # GET /cs_returns/1
        def pdf
          authorize! :print, @cs_return

          respond_to do |format|
            format.html
            format.pdf do
              if @cs_return.return_details.count < 8
                render pdf: "#{@cs_return.code}",
                  title: "#{@cs_return.code}",
                  layout: 'erp/backend/pdf',
                  page_size: 'A5',
                  orientation: 'Landscape',
                  margin: {
                    top: 7,                     # default 10 (mm)
                    bottom: 7,
                    left: 7,
                    right: 7
                  }
              else
                render pdf: "#{@cs_return.code}",
                  title: "#{@cs_return.code}",
                  layout: 'erp/backend/pdf',
                  page_size: 'A4',
                  margin: {
                    top: 7,                     # default 10 (mm)
                    bottom: 7,
                    left: 7,
                    right: 7
                  }
              end
            end
          end
        end
    
        # GET /cs_returns/new
        def new
          @cs_return = CsReturn.new
          
          authorize! :create, @cs_return
          
          @cs_return.return_date = Time.now
          @consignment = Erp::Consignments::Consignment.find(params[:consignment_id])
          @cs_return.contact = @consignment.contact
          @consignment.consignment_details.each do |consignment_detail|
            return_detail = ReturnDetail.new(
              consignment_detail_id: consignment_detail.id,
              quantity: consignment_detail.remain_quantity,
              state_id: consignment_detail.state_id
            )
            @cs_return.return_details << return_detail
          end
          
        end
    
        # GET /cs_returns/1/edit
        def edit
          authorize! :update, @cs_return
          
          @consignment = Erp::Consignments::Consignment.find(@cs_return.consignment_id)
          @consignment.consignment_details.each do |consignment_detail|
            @cs_return.return_details.build(
              consignment_detail_id: consignment_detail.id
            ) if @cs_return.return_details.where(consignment_detail_id: consignment_detail.id).empty?
          end
        end
        
        # POST /cs_returns
        def create
          @cs_return = CsReturn.new(cs_return_params)
          
          authorize! :create, @cs_return
          
          @cs_return.creator = current_user
          @cs_return.status = Erp::Consignments::CsReturn::STATUS_DELIVERED
          @consignment = Erp::Consignments::Consignment.find(@cs_return.consignment_id)
    
          if @cs_return.save
            # update consignment cache return status
            @cs_return.update_consignment_cache_return_status
            
            if request.xhr?
              render json: {
                status: 'success',
                text: @cs_return.name,
                value: @cs_return.id
              }
            else
              redirect_to erp_consignments.backend_consignments_path, notice: t('.success')
            end
          else
            render :new        
          end
        end
    
        # PATCH/PUT /cs_returns/1
        def update
          authorize! :update, @cs_return
          
          if @cs_return.update(cs_return_params)
            # update consignment cache return status
            @cs_return.update_consignment_cache_return_status
            
            if request.xhr?
              render json: {
                status: 'success',
                text: @cs_return.name,
                value: @cs_return.id
              }              
            else
              redirect_to erp_consignments.backend_consignments_path, notice: t('.success')
            end
          else
            render :edit
          end
        end
        
        # ARCHIVE /cs_returns/archive?id=1
        def archive
          authorize! :archive, @cs_return
          
          @cs_return.archive
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # UNARCHIVE /cs_returns/archive?id=1
        def unarchive
          authorize! :unarchive, @cs_return
          
          @cs_return.unarchive
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # STATUS DRAFT /cs_returns/set_draft?id=1
        def set_draft
          authorize! :set_draft, @cs_return
          
          @cs_return.set_draft
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # STATUS ACTIVE /cs_returns/set_active?id=1
        def set_active
          authorize! :set_active, @cs_return
          
          @cs_return.set_active
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # STATUS DELIVERED /cs_returns/set_delivered?id=1
        def set_delivered
          authorize! :set_delivered, @cs_return
          
          @cs_return.set_delivered
          @cs_return.update_confirmed_at
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # STATUS DELETED /cs_returns/set_deleted?id=1
        def set_deleted
          authorize! :set_deleted, @cs_return
          
          @cs_return.set_deleted
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # ARCHIVE ALL /cs_returns/archive_all?ids=1,2,3
        def archive_all         
          @cs_returns.archive_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # UNARCHIVE ALL /cs_returns/unarchive_all?ids=1,2,3
        def unarchive_all
          @cs_returns.unarchive_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # STATUS DRAFT ALL /cs_returns/set_draft_all?ids=1,2,3
        def set_draft_all         
          @cs_returns.set_draft_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # STATUS ACTIVE ALL /cs_returns/set_active_all?ids=1,2,3
        def set_active_all
          @cs_returns.set_active_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # STATUS DELIVERED ALL /cs_returns/set_delivered_all?ids=1,2,3
        def set_delivered_all         
          @cs_returns.set_delivered_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # STATUS DELETED ALL /cs_returns/set_deleted_all?ids=1,2,3
        def set_deleted_all
          @cs_returns.set_deleted_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # DATASELECT
        def dataselect
          respond_to do |format|
            format.json {
              render json: CsReturn.dataselect(params[:keyword])
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_cs_return
            @cs_return = CsReturn.find(params[:id])
          end
          
          def set_cs_returns
            @cs_returns = CsReturn.where(id: params[:ids])
          end
    
          # Only allow a trusted parameter "white list" through.
          def cs_return_params
            params.fetch(:cs_return, {}).permit(:code, :return_date, :note, :warehouse_id, :contact_id, :consignment_id,
                                                :return_details_attributes => [:id, :cs_return_id, :consignment_detail_id,
                                                                               :quantity, :state_id, :serials, :_destroy])
          end
      end
    end
  end
end