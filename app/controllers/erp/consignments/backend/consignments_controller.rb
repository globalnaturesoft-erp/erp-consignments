module Erp
  module Consignments
    module Backend
      class ConsignmentsController < Erp::Backend::BackendController
        before_action :set_consignment, only: [:archive, :unarchive, :show_list, :show, :pdf, :xlsx, :edit, :update,
                                               :set_draft, :set_active, :set_delivered, :set_deleted]
        before_action :set_consignments, only: [:delete_all, :archive_all, :unarchive_all,
                                                :set_draft_all, :set_active_all, :set_delivered_all, :set_deleted_all]

        # GET /consignments
        def index
          if Erp::Core.available?("ortho_k")
            authorize! :sales_consignments_index, nil
          end
        end

        # POST /consignments/list
        def list
          if Erp::Core.available?("ortho_k")
            authorize! :sales_consignments_index, nil
          end
          
          @consignments = Consignment.search(params).paginate(:page => params[:page], :per_page => 10)

          if params.to_unsafe_hash[:global_filter].present? and params.to_unsafe_hash[:global_filter][:consignment_from_date].present?
            @consignments = @consignments.where('sent_date >= ?', params.to_unsafe_hash[:global_filter][:consignment_from_date].to_date.beginning_of_day)
          end

          if params.to_unsafe_hash[:global_filter].present? and params.to_unsafe_hash[:global_filter][:consignment_to_date].present?
            @consignments = @consignments.where('sent_date <= ?', params.to_unsafe_hash[:global_filter][:consignment_to_date].to_date.end_of_day)
          end

          render layout: nil
        end

        def consignment_details
          @consignment = Consignment.find(params[:id])

          render layout: nil
        end

        # GET /consignments/1
        def show
          authorize! :print, @consignment

          respond_to do |format|
            format.html
            format.pdf do
              render pdf: "show_list",
                layout: 'erp/backend/pdf'
            end
          end
        end

        # POST /consignments/list
        def show_list
        end

        # GET /consignments/1
        def pdf
          authorize! :print, @consignment

          respond_to do |format|
            format.html
            format.pdf do
              if @consignment.consignment_details.count < 8
                render pdf: "#{@consignment.code}",
                  title: "#{@consignment.code}",
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
                render pdf: "#{@consignment.code}",
                  title: "#{@consignment.code}",
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
        
        # Export excel file
        def xlsx
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=\"Phieu ky gui #{@consignment.code}.xlsx\""
            }
          end
        end
        
        def export_list_xlsx
          timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
          
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
            @period_name = nil
          end
          
          @consignments = Consignment.search(params)
          
          if @from.present?
            @consignments = @consignments.where('sent_date >= ?', @from.beginning_of_day)
          end

          if @to.present?
            @consignments = @consignments.where('sent_date <= ?', @to.end_of_day)
          end
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=Danh-sach-ky-gui-va-cho-muon-u#{current_user.id}-t#{timestamp}.xlsx"
            }
          end
        end
        
        def export_cs_returns_list_xlsx
          timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
          
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
            @period_name = nil
          end
          
          @consignments = Consignment.search(params)
          
          if @from.present?
            @consignments = @consignments.where('sent_date >= ?', @from.beginning_of_day)
          end

          if @to.present?
            @consignments = @consignments.where('sent_date <= ?', @to.end_of_day)
          end
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=Danh-sach-tra-hang-ky-gui-u#{current_user.id}-t#{timestamp}.xlsx"
            }
          end
        end

        # GET /consignments/new
        def new
          @consignment = Consignment.new
          
          authorize! :create, @consignment
          
          @consignment.sent_date = Time.now
          @consignment.return_date = Time.now + 1.week
          @consignment.employee = current_user
        end

        # GET /consignments/1/edit
        def edit
          authorize! :update, @consignment
        end

        # POST /consignments
        def create
          @consignment = Consignment.new(consignment_params)
          
          authorize! :create, @consignment
          
          @consignment.creator = current_user
          @consignment.status = Consignment::STATUS_ACTIVE

          if @consignment.save
            # update cache return status
            @consignment.update_cache_return_status
            
            if request.xhr?
              render json: {
                status: 'success',
                text: @consignment.name,
                value: @consignment.id
              }
            else
              redirect_to erp_consignments.backend_consignments_path, notice: t('.success')
            end
          else
            render :new
          end
        end

        # PATCH/PUT /consignments/1
        def update
          authorize! :update, @consignment
          
          if @consignment.update(consignment_params)
            # update cache return status
            @consignment.update_cache_return_status
            
            if request.xhr?
              render json: {
                status: 'success',
                text: @consignment.name,
                value: @consignment.id
              }
            else
              redirect_to erp_consignments.backend_consignments_path, notice: t('.success')
            end
          else
            render :edit
          end
        end

        # ARCHIVE /consignments/archive?id=1
        def archive
          authorize! :archive, @consignment
          
          @consignment.archive
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # UNARCHIVE /consignments/archive?id=1
        def unarchive
          authorize! :unarchive, @consignment
          
          @consignment.unarchive
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DRAFT /consignments/set_draft?id=1
        def set_draft
          authorize! :set_draft, @consignment
          
          @consignment.set_draft
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS ACTIVE /consignments/set_active?id=1
        def set_active
          authorize! :set_active, @consignment
          
          @consignment.set_active
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELIVERED /consignments/set_delivered?id=1
        def set_delivered
          authorize! :set_delivered, @consignment
          
          @consignment.set_delivered
          @consignment.update_confirmed_at
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELETED /consignments/set_deleted?id=1
        def set_deleted
          authorize! :set_deleted, @consignment
          
          @consignment.set_deleted
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # DELETE ALL /consignments/delete_all?ids=1,2,3
        def delete_all
          @consignments.destroy_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # ARCHIVE ALL /consignments/archive_all?ids=1,2,3
        def archive_all
          @consignments.archive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # UNARCHIVE ALL /consignments/unarchive_all?ids=1,2,3
        def unarchive_all
          @consignments.unarchive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DRAFT ALL /consignments/set_draft_all?ids=1,2,3
        def set_draft_all
          @consignments.set_draft_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS ACTIVE ALL /consignments/set_active_all?ids=1,2,3
        def set_active_all
          @consignments.set_active_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELIVERED ALL /consignments/set_delivered_all?ids=1,2,3
        def set_delivered_all
          @consignments.set_delivered_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELETED ALL /consignments/set_deleted_all?ids=1,2,3
        def set_deleted_all
          @consignments.set_deleted_all

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
              render json: Consignment.dataselect(params[:keyword])
            }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_consignment
            @consignment = Consignment.find(params[:id])
          end

          def set_consignments
            @consignments = Consignment.where(id: params[:ids])
          end

          # Only allow a trusted parameter "white list" through.
          def consignment_params
            params.fetch(:consignment, {}).permit(:code, :sent_date, :return_date, :consignment_type, :warehouse_id, :contact_id, :employee_id, :note,
                                                  :consignment_details_attributes => [:id, :product_id, :quantity, :state_id, :serials, :_destroy])
          end
      end
    end
  end
end
