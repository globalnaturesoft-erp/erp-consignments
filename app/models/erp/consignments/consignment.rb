module Erp::Consignments
  class Consignment < ApplicationRecord
		validates :code, :sent_date, :return_date, :consignment_type, :employee_id, :creator_id, :presence => true
    belongs_to :employee, class_name: "Erp::User"
    belongs_to :creator, class_name: "Erp::User"
    has_many :cs_returns, class_name: "Erp::Consignments::CsReturn", dependent: :destroy
    
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
    
    has_many :consignment_details, inverse_of: :consignment, dependent: :destroy
    accepts_nested_attributes_for :consignment_details, :reject_if => lambda { |a| a[:product_id].blank? || a[:quantity].blank? || a[:quantity].to_i <= 0 }, :allow_destroy => true
    
    # class const
    TYPE_CONSIGN = 'consign'
    TYPE_LEND = 'lend'
    CONSIGNMENT_STATUS_PENDING = 'pending'
    CONSIGNMENT_STATUS_APPROVED = 'approved'
    
    # get type method options
    def self.get_consignment_type_options()
      [
        {text: I18n.t('.consign'), value: Erp::Consignments::Consignment::TYPE_CONSIGN},
        {text: I18n.t('.lend'), value: Erp::Consignments::Consignment::TYPE_LEND}
      ]
    end
    
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
      
      query = query.limit(8).map{|consignment| {value: consignment.id, text: consignment.code} }
    end
    
    def creator_name
      creator.present? ? creator.name : ''
    end
    
    def employee_name
      employee.present? ? employee.name : ''
    end
    
    def consignment_code
			return code
		end
    
    # STATUS
    def status_pending
			update_attributes(status: Erp::Consignments::Consignment::CONSIGNMENT_STATUS_PENDING)
		end
    
    def status_approved
			update_attributes(status: Erp::Consignments::Consignment::CONSIGNMENT_STATUS_APPROVED)
		end
    
    def self.status_pending_all
			update_all(status: Erp::Consignments::Consignment::CONSIGNMENT_STATUS_PENDING)
		end
    
    def self.status_approved_all
			update_all(status: Erp::Consignments::Consignment::CONSIGNMENT_STATUS_APPROVED)
		end
    
    def total_returned_quantity        
			self.consignment_details.sum(&:returned_quantity)
		end    
    
    def total_quantity
			return consignment_details.sum('quantity')
		end
    
    def total_remain_quantity        
			total_quantity - total_returned_quantity
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