class CreateEinvoices < ActiveRecord::Migration
  def change
    create_table :einvoices do |t|
      t.text :time_stamp
      t.text :merchant_id
      t.text :relate_number
      t.text :customer_id
      t.text :customer_identifier
      t.text :customer_name
      t.text :customer_addr
      t.text :customer_phone
      t.text :customer_email
      t.text :clearance_mark
      t.text :print
      t.text :donation
      t.text :love_code
      t.text :carruer_type
      t.text :carruer_num
      t.text :tax_type
      t.text :sales_amount
      t.text :invoice_remark
      t.text :item_name
      t.text :item_count
      t.text :item_word
      t.text :item_price
      t.text :item_tax_type
      t.text :item_amount
      t.text :inv_type
      t.text :inv_create_date
      t.text :vat
      t.text :invoice_number
      t.text :status

      t.timestamps null: false
    end
  end
end
