Erp::Ability.class_eval do
  def consignments_ability(user)
    
    # Consignment actions
    can :read, Erp::Consignments::Consignment
    
    can :print, Erp::Consignments::Consignment do |consignment|
      consignment.is_delivered?
    end
    
    can :update, Erp::Consignments::Consignment do |consignment|
      consignment.is_draft? or consignment.is_active? or consignment.is_delivered?
    end
    
    can :set_draft, Erp::Consignments::Consignment do |consignment|
      consignment.is_deleted?
    end
    
    can :set_active, Erp::Consignments::Consignment do |consignment|
      consignment.is_draft?
    end
    
    can :set_delivered, Erp::Consignments::Consignment do |consignment|
      (consignment.is_draft? or consignment.is_active?) and (consignment.check_stock == true)
    end
    
    can :set_deleted, Erp::Consignments::Consignment do |consignment|
      consignment.is_draft? or consignment.is_active? or consignment.is_delivered?
    end
    
    can :create_consignment_return, Erp::Consignments::Consignment do |consignment|
      consignment.is_delivered? and consignment.is_not_returned?
    end
    
    # Cs Return actions
    can :read, Erp::Consignments::CsReturn
    
    can :print, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_delivered?
    end
    
    can :update, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_draft? or cs_return.is_active? or cs_return.is_delivered?
    end
    
    can :set_draft, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_deleted?
    end
    
    can :set_active, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_draft?
    end
    
    can :set_delivered, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_draft? or cs_return.is_active?
    end
    
    can :set_deleted, Erp::Consignments::CsReturn do |cs_return|
      cs_return.is_draft? or cs_return.is_active? or cs_return.is_delivered?
    end
    
  end
end