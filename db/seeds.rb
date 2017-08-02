user = Erp::User.first
warehouses = ["ADV", "TRAINING", "TN"]
status = [Erp::Consignments::Consignment::CONSIGNMENT_STATUS_DRAFT,
          Erp::Consignments::Consignment::CONSIGNMENT_STATUS_ACTIVE,
          Erp::Consignments::Consignment::CONSIGNMENT_STATUS_DELIVERED,
          Erp::Consignments::Consignment::CONSIGNMENT_STATUS_DELETED]
consignment_type = [Erp::Consignments::Consignment::TYPE_CONSIGN,
                    Erp::Consignments::Consignment::TYPE_LEND]
# Contacts
Erp::Contacts::Contact.where(name: "Ortho-K Vietnam").destroy_all
owner = Erp::Contacts::Contact.create(
  contact_type: Erp::Contacts::Contact::TYPE_COMPANY,
  name: "Ortho-K Vietnam",
  code: "OTK001",
  address: "535 An Duong Vuong, Ward 8, Dist.5, HCMC",
  creator_id: user.id
)
puts owner.errors.to_json if !owner.errors.empty?

# Warehouses
Erp::Warehouses::Warehouse.all.destroy_all
warehouses.each do |name|
  wh = Erp::Warehouses::Warehouse.create(
    name: name,
    short_name: name,
    creator_id: user.id,
    contact_id: owner.id
  )
end

# Stock Transfers
Erp::Consignments::Consignment.all.destroy_all
count = 0
count_b = 0
(1..50).each do |num|          
  contact_ps = Erp::Contacts::Contact.where(contact_type: Erp::Contacts::Contact::TYPE_PERSON).order("RANDOM()").first
  ws = Erp::Warehouses::Warehouse.where(id: Erp::Warehouses::Warehouse.pluck(:id).sample(2))
  consignment = Erp::Consignments::Consignment.create(
    code: 'KG'+ num.to_s.rjust(3, '0'),
    sent_date: Time.now,
    return_date: Time.now + 1.week,
    contact_id: contact_ps.id,
    status: status[rand(status.count)],
    warehouse_id: ws.first.id,
    consignment_type: consignment_type[rand(consignment_type.count)],
    employee_id: user.id,
    creator_id: user.id
  )
  count_b += 1
  puts "BIG: " + count_b.to_s
  puts consignment.errors.to_json if !consignment.errors.empty?
  Erp::Products::Product.where(id: Erp::Products::Product.pluck(:id).sample(rand(1..6))).each do |product|
    cs_detail = Erp::Consignments::ConsignmentDetail.create(
      product_id: product.id,      
      consignment_id: consignment.id,
      quantity: rand(1..50)
    )
    count += 1
    puts "###########################BIG: " + count_b.to_s + " / " + count.to_s
    puts cs_detail.errors.to_json if !cs_detail.errors.empty?
  end
end