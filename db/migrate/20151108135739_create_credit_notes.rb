class CreateCreditNotes < ActiveRecord::Migration
  def change
    create_table :credit_notes do |t|
      t.integer :einvoice_id
      t.text :ia_allow_no
      t.text :ia_invoice_no
      t.text :ia_date
      t.text :ia_remain_allowance_amt
      t.text :status

      t.timestamps null: false
    end
  end
end
