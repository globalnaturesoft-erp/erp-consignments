Erp::Consignments::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "backend/consignments" do
			resources :consignments do
				collection do
					post 'list'
					get 'consignment_details'
					get 'dataselect'
					delete 'delete_all'
					put 'set_draft'
					put 'set_active'
					put 'set_delivered'
					put 'set_deleted'
					put 'set_draft_all'
					put 'set_active_all'
					put 'set_delivered_all'
					put 'set_deleted_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
					post 'show_list'
					get 'pdf'
					get 'xlsx'
					get 'export_list_xlsx'
					get 'export_detail_xlsx'
					get 'export_cs_returns_list_xlsx'
				end
			end
			resources :cs_returns do
				collection do
					post 'list'
					get 'return_details'
					get 'dataselect'
					delete 'delete_all'
					put 'set_draft'
					put 'set_active'
					put 'set_delivered'
					put 'set_deleted'
					put 'set_draft_all'
					put 'set_active_all'
					put 'set_delivered_all'
					put 'set_deleted_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
					post 'show_list'
					get 'pdf'
					get 'xlsx'
				end
			end
			resources :consignment_details do
				collection do
          get 'consignment_detail_line_form'
				end
			end
		end
	end
end