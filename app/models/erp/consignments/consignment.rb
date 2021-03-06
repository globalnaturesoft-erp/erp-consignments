module Erp::Consignments
  class Consignment < ApplicationRecord
		validates :code, uniqueness: true
		validates :sent_date, :return_date, :consignment_type, :employee_id, :creator_id, :presence => true
    belongs_to :employee, class_name: "Erp::User"
    belongs_to :creator, class_name: "Erp::User"
    has_many :cs_returns, class_name: "Erp::Consignments::CsReturn", dependent: :destroy
    
    def delivered_cs_returns
      cs_returns.get_delivered
    end

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
    STATUS_DRAFT = 'draft'
    STATUS_ACTIVE = 'active'
    STATUS_DELIVERED = 'delivered'
    STATUS_DELETED = 'deleted'
    
    RETURN_STATUS_RETURNED = 'returned'
    RETURN_STATUS_NOT_RETURNED = 'not_returned'
    RETURN_STATUS_OVER_RETURNED = 'over_returned'

    # get type method options
    def self.get_consignment_type_options()
      [
        {text: I18n.t('.consign'), value: Erp::Consignments::Consignment::TYPE_CONSIGN},
        {text: I18n.t('.lend'), value: Erp::Consignments::Consignment::TYPE_LEND}
      ]
    end
    
    # get not delivered consignments
    def self.get_not_delivered_consignments
      self.where(status: [
          Erp::Consignments::Consignment::STATUS_ACTIVE,
          Erp::Consignments::Consignment::STATUS_DRAFT
      ])
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

       # global filter
      global_filter = params[:global_filter]

      if global_filter.present?
        # if has period
        if global_filter[:period].present?
          period = Erp::Periods::Period.find(global_filter[:period])
          global_filter[:from_date] = period.from_date
          global_filter[:to_date] = period.to_date
        end

				# filter by order from date
				if global_filter[:from_date].present?
					query = query.where('sent_date >= ?', global_filter[:from_date].to_date.beginning_of_day)
				end

				# filter by order to date
				if global_filter[:to_date].present?
					query = query.where('sent_date <= ?', global_filter[:to_date].to_date.end_of_day)
				end

				# filter by consignment contact
				if global_filter[:contact].present?
					query = query.where(contact_id: global_filter[:contact])
				end

				if global_filter[:warehouse].present?
					query = query.where(warehouse_id: global_filter[:warehouse])
				end
			end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(erp_consignments_consignments.cache_search) LIKE ?', '%'+q+'%')
				end
			end

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

    # check if consign/lend
    def consign?
			return consignment_type == Erp::Consignments::Consignment::TYPE_CONSIGN
		end

    def lend?
			return consignment_type == Erp::Consignments::Consignment::TYPE_LEND
		end

    # STATUS
    def set_draft
			update_attributes(status: Erp::Consignments::Consignment::STATUS_DRAFT)
		end

    def set_active
			update_attributes(status: Erp::Consignments::Consignment::STATUS_ACTIVE)
		end

    def set_delivered
			update_attributes(status: Erp::Consignments::Consignment::STATUS_DELIVERED)
		end

    def set_deleted
			update_attributes(status: Erp::Consignments::Consignment::STATUS_DELETED)
		end

    def self.set_draft_all
			update_all(status: Erp::Consignments::Consignment::STATUS_DRAFT)
		end

    def self.set_active_all
			update_all(status: Erp::Consignments::Consignment::STATUS_ACTIVE)
		end

    def self.set_delivered_all
			update_all(status: Erp::Consignments::Consignment::STATUS_DELIVERED)
		end

    def self.set_deleted_all
			update_all(status: Erp::Consignments::Consignment::STATUS_DELETED)
		end

    def total_returned_quantity
			self.consignment_details.sum(&:returned_quantity)
		end

    def total_quantity
			return consignment_details.sum(:quantity)
		end

    def total_remain_quantity
			total_quantity - total_returned_quantity
		end
    
    def self.total_quantity
      self.sum(&:total_quantity)
    end
    
    def self.total_returned_quantity
      self.sum(&:total_returned_quantity)
    end
    
    def self.total_remain_quantity
      self.sum(&:total_remain_quantity)
    end
    
    def return_status
      remain = total_remain_quantity
      if remain > 0
        return Erp::Consignments::Consignment::RETURN_STATUS_NOT_RETURNED
      elsif remain == 0
        return Erp::Consignments::Consignment::RETURN_STATUS_RETURNED
      else
        return Erp::Consignments::Consignment::RETURN_STATUS_OVER_RETURNED
      end
    end
    
    after_save :update_cache_return_status
    def update_cache_return_status
      self.update_column(:cache_return_status, self.return_status)
    end
    
    # Check is return status
    def is_returned?
      return cache_return_status == Erp::Consignments::Consignment::RETURN_STATUS_RETURNED
    end
    
    def is_not_returned?
      return cache_return_status == Erp::Consignments::Consignment::RETURN_STATUS_NOT_RETURNED
    end
    
    def is_over_returned?
      return cache_return_status == Erp::Consignments::Consignment::RETURN_STATUS_OVER_RETURNED
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
    
    # check if status
    def is_draft?
			return status == Erp::Consignments::Consignment::STATUS_DRAFT
		end

    def is_active?
			return status == Erp::Consignments::Consignment::STATUS_ACTIVE
		end

    def is_delivered?
			return status == Erp::Consignments::Consignment::STATUS_DELIVERED
		end

    def is_deleted?
			return status == Erp::Consignments::Consignment::STATUS_DELETED
		end
    
    def check_stock
      self.consignment_details.each do |cd|
        if cd.quantity > cd.product.get_stock(warehouse_ids: self.warehouse_id, state_ids: cd.state_id)
          return false
        end
      end
      return true
    end
    
    def check_stock_status
      if status == Erp::Consignments::Consignment::STATUS_ACTIVE
        if check_stock == false
          'out_of_stock'
        else
          'in_stock'
        end
      end
    end
    
    # update confirmed at
    def update_confirmed_at
      self.update_columns(confirmed_at: Time.now)
    end

    # Generate code
    before_validation :generate_code
    def generate_code
			if !code.present?
				if consign?
					query = Erp::Consignments::Consignment.where(consignment_type: Erp::Consignments::Consignment::TYPE_CONSIGN)
				elsif lend?
					query = Erp::Consignments::Consignment.where(consignment_type: Erp::Consignments::Consignment::TYPE_LEND)
				end

				str = (consign? ? 'KG' : 'XM')
				num = query.where('sent_date >= ? AND sent_date <= ?', self.sent_date.beginning_of_month, self.sent_date.end_of_month).count + 1

				self.code = str + sent_date.strftime("%m") + sent_date.strftime("%Y").last(2) + "-" + num.to_s.rjust(3, '0')
			end
		end
    
    # Update casche search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << consignment_code.to_s.downcase.strip
			str << contact_name.to_s.downcase.strip
			str << warehouse_name.to_s.downcase.strip
			str << employee_name.to_s.downcase.strip
			str << creator_name.to_s.downcase.strip
			consignment_details.each do |cd|
        str << cd.get_product_name.to_s.downcase.strip
			end

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
  end
end
