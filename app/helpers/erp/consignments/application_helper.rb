module Erp
  module Consignments
    module ApplicationHelper
      # Consignment dropdown actions
      def consignment_dropdown_actions(consignment)
        actions = []
        actions << {
          text: '<i class="fa fa-print"></i> '+t('.view_print'),
          url: erp_consignments.backend_consignment_path(consignment)
        } if can? :print, consignment
        
        actions << {
          text: '<i class="fa fa-file-excel-o"></i> Xuất excel',
          url: erp_consignments.xlsx_backend_consignments_path(id: consignment.id, format: 'xlsx'),
          target: '_blank'
        } if true
        
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('edit'),
          url: erp_consignments.edit_backend_consignment_path(consignment)
        } if can? :update, consignment
        
        actions << {
          text: '<i class="fa fa-sticky-note-o"></i> '+t('.change_draft'),
          url: erp_consignments.status_draft_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :set_draft, consignment
        
        actions << {
          text: '<i class="fa fa-check"></i> '+t('.change_active'),
          url: erp_consignments.status_active_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :set_active, consignment
        
        actions << {
          text: '<i class="fa fa-truck"></i> '+t('.change_delivered'),
          url: erp_consignments.status_delivered_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :set_delivered, consignment
        
        actions << {
          text: '<i class="fa fa-reply-all"></i> '+t('.create_return'),
          url: erp_consignments.new_backend_cs_return_path(consignment_id: consignment.id)
        } if can? :create_consignment_return, consignment
        
        actions << { divider: true } if can? :set_deleted, consignment
        
        actions << {
          text: '<i class="glyphicon glyphicon-trash"></i> '+t('.change_deleted'),
          url: erp_consignments.status_deleted_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.change_deleted_confirm')
        } if can? :set_deleted, consignment
        
        erp_datalist_row_actions(
          actions
        )
      end

      # Consignment-Return dropdown actions
      def cs_return_dropdown_actions(cs_return)
        actions = []
        
        actions << {
          text: '<i class="fa fa-print"></i> '+t('.view_print'),
          url: erp_consignments.backend_cs_return_path(cs_return),
          class: 'modal-link'
        } if can? :print, cs_return
        
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('.edit'),
          href: erp_consignments.edit_backend_cs_return_path(cs_return),
          target: '_blank'
        }
        
        actions << { divider: true } if (can? :set_draft, cs_return) or (can? :set_active, cs_return) or (can? :set_delivered, cs_return)
        
        actions << {
          text: '<i class="fa fa-sticky-note-o"></i> '+t('.set_draft'),
          url: erp_consignments.status_draft_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :set_draft, cs_return
        
        actions << {
          text: '<i class="fa fa-check"></i> '+t('.set_active'),
          url: erp_consignments.status_active_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :set_active, cs_return
        
        actions << {
          text: '<i class="glyphicon glyphicon-arrow-right"></i> '+t('.set_delivered'),
          url: erp_consignments.status_delivered_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :set_delivered, cs_return
        
        actions << { divider: true } if can? :set_deleted, cs_return
        
        actions << {
          text: '<i class="glyphicon glyphicon-trash"></i> '+t('.set_deleted'),
          url: erp_consignments.status_deleted_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.set_deleted_confirm')
        } if can? :set_deleted, cs_return
        
        erp_datalist_row_actions(
          actions
        )
      end
    end
  end
end
