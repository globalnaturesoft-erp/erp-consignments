Erp::Consignments::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "backend/consignments" do
			resources :consignments do
				collection do
					post 'list'
					get 'consignment_details'
					get 'dataselect'
					delete 'delete_all'
					put 'status_draft'
					put 'status_active'
					put 'status_delivered'
					put 'status_deleted'
					put 'status_draft_all'
					put 'status_active_all'
					put 'status_delivered_all'
					put 'status_deleted_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
				end
			end
			resources :cs_returns do
				collection do
					post 'list'
					get 'return_details'
					get 'dataselect'
					delete 'delete_all'
					put 'status_draft'
					put 'status_active'
					put 'status_delivered'
					put 'status_deleted'
					put 'status_draft_all'
					put 'status_active_all'
					put 'status_delivered_all'
					put 'status_deleted_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
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