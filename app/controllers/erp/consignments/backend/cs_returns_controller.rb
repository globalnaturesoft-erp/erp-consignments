module Erp
  module Consignments
    module Backend
      class CsReturnsController < Erp::Backend::BackendController
        before_action :set_cs_return, only: [:archive, :unarchive, :status_pending, :status_approved, :edit, :update, :destroy]
        before_action :set_cs_returns, only: [:delete_all, :archive_all, :status_pending_all, :status_approved_all, :unarchive_all]
    
        # GET /cs_returns
        def index
        end
    
        # POST /cs_returns/list
        def list
          @cs_returns = CsReturn.search(params).paginate(:page => params[:page], :per_page => 10)
          
          render layout: nil
        end
        
        def return_details
          @cs_return = CsReturn.find(params[:id])
          
          render layout: nil
        end
    
        # GET /cs_returns/new
        def new
          @cs_return = CsReturn.new
          @cs_return.return_date = Time.now
          @consignment = Erp::Consignments::Consignment.find(params[:consignment_id])
          @consignment.consignment_details.each do |od|
            dt = ReturnDetail.new(
              consignment_detail_id: od.id
            )
            @cs_return.return_details << dt
          end
        end
    
        # GET /cs_returns/1/edit
        def edit
          @consignment = Erp::Consignments::Consignment.find(@cs_return.consignment_id)
          @consignment.consignment_details.each do |od|
            @cs_return.return_details.build(
              consignment_detail_id: od.id
            ) if @cs_return.return_details.where(consignment_detail_id: od.id).empty?
          end
        end
    
        # POST /cs_returns
        def create
          @cs_return = CsReturn.new(cs_return_params)
          @cs_return.creator = current_user
    
          if @cs_return.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @cs_return.name,
                value: @cs_return.id
              }
            else
              redirect_to erp_consignments.edit_backend_cs_return_path(@cs_return), notice: t('.success')
            end
          else
            render :new        
          end
        end
    
        # PATCH/PUT /cs_returns/1
        def update
          if @cs_return.update(cs_return_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @cs_return.name,
                value: @cs_return.id
              }              
            else
              redirect_to erp_consignments.edit_backend_cs_return_path(@cs_return), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /cs_returns/1
        def destroy
          @cs_return.destroy

          respond_to do |format|
            format.html { redirect_to erp_consignments.backend_cs_returns_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # ARCHIVE /cs_returns/archive?id=1
        def archive
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
        
        # STATUS PENDING /cs_returns/status_pending?id=1
        def status_pending
          @cs_return.status_pending
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # STATUS APPROVED /cs_returns/status_approved?id=1
        def status_approved
          @cs_return.status_approved
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # DELETE ALL /cs_returns/delete_all?ids=1,2,3
        def delete_all         
          @cs_returns.destroy_all
          
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
        
        # STATUS PENDING ALL /cs_returns/status_pending_all?ids=1,2,3
        def status_pending_all         
          @cs_returns.status_pending_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # STATUS APPROVED ALL /cs_returns/status_approved_all?ids=1,2,3
        def status_approved_all
          @cs_returns.status_approved_all
          
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
            params.fetch(:cs_return, {}).permit(:code, :return_date, :note, :contact_id, :consignment_id,
                                                  :return_details_attributes => [:id, :cs_return_id, :consignment_detail_id, :quantity, :_destroy])
          end
      end
    end
  end
end