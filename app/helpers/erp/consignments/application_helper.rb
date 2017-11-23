module Erp
  module Consignments
    module ApplicationHelper
      # Consignment dropdown actions
      def consignment_dropdown_actions(consignment)
        actions = []
        actions << {
          text: '<i class="fa fa-print"></i> '+t('.view_print'),
          url: erp_consignments.backend_consignment_path(consignment)
        }
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('.edit'),
          url: erp_consignments.edit_backend_consignment_path(consignment)
        }
        actions << {
          text: '<i class="fa fa-file-text"></i> '+t('.create_return'),
          url: erp_consignments.new_backend_cs_return_path(consignment_id: consignment.id)
        }
        actions << { divider: true }
        actions << {
          text: '<i class="fa fa-file-o"></i> '+t('.change_draft'),
          url: erp_consignments.status_draft_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          hide: consignment.status == Erp::Consignments::Consignment::STATUS_DRAFT,
          class: 'ajax-link'
        }
        actions << {
          text: '<i class="fa fa-file-text-o"></i> '+t('.change_active'),
          url: erp_consignments.status_active_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          hide: consignment.status == Erp::Consignments::Consignment::STATUS_ACTIVE,
          hide: consignment.status == Erp::Consignments::Consignment::STATUS_DELIVERED,
          class: 'ajax-link'
        }
        actions << {
          text: '<i class="fa fa-file-text"></i> '+t('.change_delivered'),
          url: erp_consignments.status_delivered_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          hide: consignment.status == Erp::Consignments::Consignment::STATUS_DRAFT,
          class: 'ajax-link'
        }
        actions << { divider: true }
        actions << {
          text: '<i class="fa fa-close"></i> '+t('.change_deleted'),
          url: erp_consignments.status_deleted_backend_consignments_path(id: consignment),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.change_deleted_confirm')
        }
        erp_datalist_row_actions(
          actions
        )
      end

      # Consignment-Return dropdown actions
      def cs_return_dropdown_actions(cs_return)
        actions = []
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('.edit'),
          href: erp_consignments.edit_backend_cs_return_path(cs_return)
        }
        actions << { divider: true }
        actions << {
          text: '<i class="fa fa-file-o"></i> '+t('.change_draft'),
          url: erp_consignments.status_draft_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          hide: cs_return.status == Erp::Consignments::CsReturn::STATUS_DRAFT,
          class: 'ajax-link'
        }
        actions << {
          text: '<i class="fa fa-file-text-o"></i> '+t('.change_active'),
          url: erp_consignments.status_active_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          hide: cs_return.status == Erp::Consignments::CsReturn::STATUS_ACTIVE,
          hide: cs_return.status == Erp::Consignments::CsReturn::STATUS_DELIVERED,
          class: 'ajax-link'
        }
        actions << {
          text: '<i class="fa fa-file-text"></i> '+t('.change_delivered'),
          url: erp_consignments.status_delivered_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          hide: cs_return.status == Erp::Consignments::CsReturn::STATUS_DRAFT,
          class: 'ajax-link'
        }
        actions << { divider: true }
        actions << {
          text: '<i class="fa fa-close"></i> '+t('.change_deleted'),
          url: erp_consignments.status_deleted_backend_cs_returns_path(id: cs_return),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.change_deleted_confirm')
        }
        erp_datalist_row_actions(
          actions
        )
      end
    end
  end
end
