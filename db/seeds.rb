user = Erp::User.first
status = [Erp::Consignments::Consignment::CONSIGNMENT_STATUS_DRAFT,
          Erp::Consignments::Consignment::CONSIGNMENT_STATUS_ACTIVE,
          Erp::Consignments::Consignment::CONSIGNMENT_STATUS_DELIVERED,
          Erp::Consignments::Consignment::CONSIGNMENT_STATUS_DELETED]
consignment_type = [Erp::Consignments::Consignment::TYPE_CONSIGN,
                    Erp::Consignments::Consignment::TYPE_LEND]

# Stock Transfers
Erp::Consignments::Consignment.all.destroy_all
(1..50).each do |num|          
  contact = Erp::Contacts::Contact.where(contact_type: Erp::Contacts::Contact::TYPE_PERSON).order("RANDOM()").first
  warehouse = Erp::Warehouses::Warehouse.order("RANDOM()").first
  consignment = Erp::Consignments::Consignment.create(
    code: 'KG'+ num.to_s.rjust(3, '0'),
    sent_date: Time.current,
    return_date: Time.current + 1.week,
    contact_id: contact.id,
    status: status[rand(status.count)],
    warehouse_id: warehouse.id,
    consignment_type: consignment_type[rand(consignment_type.count)],
    employee_id: user.id,
    creator_id: user.id
  )
  (puts '===== ERRORs =====' + consignment.errors.to_json) if !consignment.errors.empty?
  Erp::Products::Product.where(id: Erp::Products::Product.pluck(:id).sample(rand(1..6))).each do |product|
    cs_detail = Erp::Consignments::ConsignmentDetail.create(
      product_id: product.id,
      consignment_id: consignment.id,
      quantity: rand(1..50)
    )
    (puts '===== ERRORs =====' + cs_detail.errors.to_json) if !cs_detail.errors.empty?
  end
end
