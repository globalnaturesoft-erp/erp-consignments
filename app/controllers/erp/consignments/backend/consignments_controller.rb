module Erp
  module Consignments
    module Backend
      class ConsignmentsController < Erp::Backend::BackendController
        before_action :set_consignment, only: [:archive, :unarchive, :status_draft, :status_active, :status_delivered, :status_deleted,
                                               :show_list, :show, :pdf, :xlsx, :edit, :update]
        before_action :set_consignments, only: [:delete_all, :archive_all, :unarchive_all, :status_draft_all, :status_active_all, :status_delivered_all, :status_deleted_all]

        # GET /consignments
        def index
        end

        # POST /consignments/list
        def list
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
          #authorize! :print, @consignment

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
          #authorize! :print, @consignment

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
        
        def xlsx
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename='Phieu ky gui #{@consignment.code}.xlsx'"
            }
          end
        end

        # GET /consignments/new
        def new
          @consignment = Consignment.new
          @consignment.sent_date = Time.now
          @consignment.return_date = Time.now + 1.week
          @consignment.employee = current_user
        end

        # GET /consignments/1/edit
        def edit
        end

        # POST /consignments
        def create
          @consignment = Consignment.new(consignment_params)
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

        # STATUS DRAFT /consignments/status_draft?id=1
        def status_draft
          @consignment.status_draft
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS ACTIVE /consignments/status_active?id=1
        def status_active
          @consignment.status_active
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELIVERED /consignments/status_delivered?id=1
        def status_delivered
          @consignment.status_delivered
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELETED /consignments/status_deleted?id=1
        def status_deleted
          @consignment.status_deleted
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

        # STATUS DRAFT ALL /consignments/status_draft_all?ids=1,2,3
        def status_draft_all
          @consignments.status_draft_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS ACTIVE ALL /consignments/status_active_all?ids=1,2,3
        def status_active_all
          @consignments.status_active_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELIVERED ALL /consignments/status_delivered_all?ids=1,2,3
        def status_delivered_all
          @consignments.status_delivered_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # STATUS DELETED ALL /consignments/status_deleted_all?ids=1,2,3
        def status_deleted_all
          @consignments.status_deleted_all

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
                                                  :consignment_details_attributes => [:id, :product_id, :quantity, :state_id, :_destroy])
          end
      end
    end
  end
end
