Erp::Ability.class_eval do
  def consignments_ability(user)
    
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
      consignment.is_delivered?
    end
  end
end