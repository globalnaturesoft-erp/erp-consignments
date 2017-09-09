module Erp::Consignments
  class CsReturn < ApplicationRecord
    validates :return_date, :consignment_id, :creator_id, :presence => true
    belongs_to :consignment, class_name: "Erp::Consignments::Consignment"
    belongs_to :creator, class_name: "Erp::User"
    
    if Erp::Core.available?("contacts")
			validates :contact_id, :presence => true
      belongs_to :contact, class_name: "Erp::Contacts::Contact", foreign_key: :contact_id
      
      def contact_name
        contact.present? ? contact.contact_name : ''
      end
    end
    
    if Erp::Core.available?("warehouses")
			validates :warehouse_id, :presence => true
      belongs_to :warehouse, class_name: "Erp::Warehouses::Warehouse"
      
      def warehouse_name
        warehouse.present? ? warehouse.warehouse_name : ''
      end
    end
    
    has_many :return_details, inverse_of: :cs_return, dependent: :destroy
    accepts_nested_attributes_for :return_details, :reject_if => lambda { |a| a[:consignment_detail_id].blank? || a[:quantity].blank? || a[:quantity].to_i <= 0 }, :allow_destroy => true
    
    # class const
    CS_RETURN_STATUS_DRAFT = 'draft'
    CS_RETURN_STATUS_ACTIVE = 'active'
    CS_RETURN_STATUS_DELIVERED = 'delivered'
    CS_RETURN_STATUS_DELETED = 'deleted'
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []
      
      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            # in case filter is show archived
            if cond[1]["name"] == 'show_archived'
              show_archived = true
            else
              or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
            end
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end
      
      # show archived items condition - default: false
      show_archived = false
      
      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            # in case filter is show archived
            if cond[1]["name"] == 'show_archived'
              # show archived items
              show_archived = true
            else
              or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
            end
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end
      
      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end

      # join with users table for search creator
      query = query.joins(:creator)
      
      if Erp::Core.available?("contacts")
				# join with contacts table for search contact
				query = query.joins(:contact)
			end
      
      # showing archived items if show_archived is not true
      query = query.where(archived: false) if show_archived == false
      
      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?
      
      return query
    end
    
    def self.search(params)
      query = self.all
      query = self.filter(query, params)
      
      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?
        
        query = query.order(order)
      end
      
      return query
    end
    
    # data for dataselect ajax
    def self.dataselect(keyword='')
      query = self.all
      
      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(code) LIKE ?', "%#{keyword}%")
      end
      
      query = query.limit(8).map{|cs_return| {value: cs_return.id, text: cs_return.code} }
    end
    
    def creator_name
      creator.present? ? creator.name : ''
    end
    
    # STATUS
    def status_draft
			update_attributes(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_DRAFT)
		end
    
    def status_active
			update_attributes(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_ACTIVE)
		end
    
    def status_delivered
			update_attributes(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_DELIVERED)
		end
    
    def status_deleted
			update_attributes(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_DELETED)
		end
    
    def self.status_draft_all
			update_all(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_DRAFT)
		end
    
    def self.status_active_all
			update_all(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_ACTIVE)
		end
    
    def self.status_delivered_all
			update_all(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_DELIVERED)
		end
    
    def self.status_deleted_all
			update_all(status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_DELETED)
		end
    
    def total_quantity        
			self.return_details.sum(:quantity)
		end
    
    # ARCHIVE
    def archive
			update_attributes(archived: true)
		end
    
    def unarchive
			update_attributes(archived: false)
		end
    
    def self.archive_all
			update_all(archived: true)
		end
    
    def self.unarchive_all
			update_all(archived: false)
		end
  end
end
