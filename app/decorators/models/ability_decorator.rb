Erp::Ability.class_eval do
  def consignments_ability(user)
    
    # Consignment actions
    can :read, Erp::Consignments::Consignment
    
    can :create, Erp::Consignments::Consignment do |consignment|
      if Erp::Core.available?("ortho_k")
        user.get_permission(:sales, :consignments, :consignments, :create) == 'yes'
      else
        true
      end
    end
    
    can :print, Erp::Consignments::Consignment do |consignment|
      consignment.is_delivered?
    end
    
    can :excel_export, Erp::Consignments::Consignment do |consignment|
      !consignment.is_deleted?
    end
    
    can :update, Erp::Consignments::Consignment do |consignment|
      if Erp::Core.available?("ortho_k")
        (consignment.is_draft? or consignment.is_active? or consignment.is_delivered?) and
        user.get_permission(:sales, :consignments, :consignments, :update) == 'yes' or
        (
          user.get_permission(:sales, :consignments, :consignments, :update) == 'in_day' and
          (consignment.confirmed_at.nil? or (Time.now < consignment.confirmed_at.end_of_day and consignment.is_delivered?))
        )
      else
        consignment.is_draft? or consignment.is_active? or consignment.is_delivered?
      end
    end
    
    can :archive, Erp::Consignments::Consignment do |consignment|
      false
    end
    
    can :unarchive, Erp::Consignments::Consignment do |consignment|
      false
    end
    
    can :set_draft, Erp::Consignments::Consignment do |consignment|
      false
    end
    
    can :set_active, Erp::Consignments::Consignment do |consignment|
      consignment.is_draft?
    end
    
    can :set_delivered, Erp::Consignments::Consignment do |consignment|
      (consignment.is_draft? or consignment.is_active?) and (consignment.check_stock == true)
    end
    
    can :set_deleted, Erp::Consignments::Consignment do |consignment|
      if Erp::Core.available?("ortho_k")
        (consignment.is_draft? or consignment.is_active? or consignment.is_delivered?) and
        user.get_permission(:sales, :consignments, :consignments, :delete) == 'yes'
      else
        consignment.is_draft? or consignment.is_active? or consignment.is_delivered?
      end
    end
    
    can :create_consignment_return, Erp::Consignments::Consignment do |consignment|
      if Erp::Core.available?("ortho_k")
        (consignment.is_delivered? and consignment.is_not_returned?) and
        user.get_permission(:sales, :consignments, :cs_returns, :create) == 'yes'
      else
        consignment.is_delivered? and consignment.is_not_returned?
      end
    end
    
    # Cs Return actions
    can :read, Erp::Consignments::CsReturn
    
    can :create, Erp::Consignments::CsReturn do |cs_return|
      if Erp::Core.available?("ortho_k")
        user.get_permission(:sales, :consignments, :cs_returns, :create) == 'yes'
      else
        true
      end
    end
    
    can :print, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_delivered?
    end
    
    can :excel_export, Erp::Consignments::CsReturn do |cs_return|
      !cs_return.is_deleted?
    end
    
    can :update, Erp::Consignments::CsReturn do |cs_return|
      if Erp::Core.available?("ortho_k")
        (cs_return.is_draft? or cs_return.is_active? or cs_return.is_delivered?) and
        user.get_permission(:sales, :consignments, :cs_returns, :update) == 'yes' or
        (
          user.get_permission(:sales, :consignments, :cs_returns, :update) == 'in_day' and
          (cs_return.confirmed_at.nil? or (Time.now < cs_return.confirmed_at.end_of_day and cs_return.is_delivered?))
        )
      else
        cs_return.is_draft? or cs_return.is_active? or cs_return.is_delivered?
      end
      
    end
    
    can :set_draft, Erp::Consignments::CsReturn do |cs_return|
      false
    end
    
    can :set_active, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_draft?
    end
    
    can :set_delivered, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_draft? or cs_return.is_active?
    end
    
    can :set_deleted, Erp::Consignments::CsReturn do |cs_return|
      if Erp::Core.available?("ortho_k")
        (cs_return.is_draft? or cs_return.is_active? or cs_return.is_delivered?) and
        user.get_permission(:sales, :consignments, :cs_returns, :delete) == 'yes'
      else
        cs_return.is_draft? or cs_return.is_active? or cs_return.is_delivered?
      end
    end
    
  end
end