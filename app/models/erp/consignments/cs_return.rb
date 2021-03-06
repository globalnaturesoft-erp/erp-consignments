module Erp::Consignments
  class CsReturn < ApplicationRecord
		validates :code, uniqueness: true
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
    
    def consignment_code
      consignment.present? ? consignment.code : ''
    end
    
    def consignment_employee_name
      consignment.present? ? consignment.employee_name : ''
    end
    
    has_many :return_details, inverse_of: :cs_return, dependent: :destroy
    accepts_nested_attributes_for :return_details, :reject_if => lambda { |a| a[:consignment_detail_id].blank? || a[:quantity].blank? || a[:quantity].to_i <= 0 }, :allow_destroy => true
    
    # class const
    STATUS_DRAFT = 'draft'
    STATUS_ACTIVE = 'active'
    STATUS_DELIVERED = 'delivered'
    STATUS_DELETED = 'deleted'
    
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
    def set_draft
			update_attributes(status: Erp::Consignments::CsReturn::STATUS_DRAFT)
		end
    
    def set_active
			update_attributes(status: Erp::Consignments::CsReturn::STATUS_ACTIVE)
		end
    
    def set_delivered
			update_attributes(status: Erp::Consignments::CsReturn::STATUS_DELIVERED)
		end
    
    def set_deleted
			update_attributes(status: Erp::Consignments::CsReturn::STATUS_DELETED)
		end
    
    def self.set_draft_all
			update_all(status: Erp::Consignments::CsReturn::STATUS_DRAFT)
		end
    
    def self.set_active_all
			update_all(status: Erp::Consignments::CsReturn::STATUS_ACTIVE)
		end
    
    def self.set_delivered_all
			update_all(status: Erp::Consignments::CsReturn::STATUS_DELIVERED)
		end
    
    def self.set_deleted_all
			update_all(status: Erp::Consignments::CsReturn::STATUS_DELETED)
		end
    
    def total_quantity        
			self.return_details.sum(:quantity)
		end
    
    def self.total_quantity        
			self.sum(&:total_quantity)
		end
    
    def self.get_delivered
      self.where(status: self::STATUS_DELIVERED)
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
    
    def is_draft?
			return status == Erp::Consignments::CsReturn::STATUS_DRAFT
		end
    
    def is_active?
			return status == Erp::Consignments::CsReturn::STATUS_ACTIVE
		end
    
    def is_delivered?
			return status == Erp::Consignments::CsReturn::STATUS_DELIVERED
		end
    
    def is_deleted?
			return status == Erp::Consignments::CsReturn::STATUS_DELETED
		end
    
    def cs_return_consign?
			return consignment.consignment_type == Erp::Consignments::Consignment::TYPE_CONSIGN
		end
    
    def cs_return_lend?
			return consignment.consignment_type == Erp::Consignments::Consignment::TYPE_LEND
		end
    
    # update confirmed at
    def update_confirmed_at
      self.update_columns(confirmed_at: Time.now)
    end
    
    # Generate code
    before_validation :generate_code
    def generate_code
			if !code.present?
				query = Erp::Consignments::CsReturn
				
				str = 'TL' # TL: trả lại
				num = query.where('erp_consignments_cs_returns.return_date >= ? AND erp_consignments_cs_returns.return_date <= ?', self.return_date.beginning_of_month, self.return_date.end_of_month).count + 1
				
				self.code = str + return_date.strftime("%m") + return_date.strftime("%Y").last(2) + "-" + num.to_s.rjust(3, '0')
			end
		end
    
    after_save :update_consignment_cache_return_status
    def update_consignment_cache_return_status
      consignment.update_cache_return_status
    end
  end
end
