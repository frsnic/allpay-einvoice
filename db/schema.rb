# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151108135739) do

  create_table "credit_notes", force: :cascade do |t|
    t.integer  "einvoice_id"
    t.text     "ia_allow_no"
    t.text     "ia_invoice_no"
    t.text     "ia_date"
    t.text     "ia_remain_allowance_amt"
    t.text     "status"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "einvoices", force: :cascade do |t|
    t.text     "time_stamp"
    t.text     "merchant_id"
    t.text     "relate_number"
    t.text     "customer_id"
    t.text     "customer_identifier"
    t.text     "customer_name"
    t.text     "customer_addr"
    t.text     "customer_phone"
    t.text     "customer_email"
    t.text     "clearance_mark"
    t.text     "print"
    t.text     "donation"
    t.text     "love_code"
    t.text     "carruer_type"
    t.text     "carruer_num"
    t.text     "tax_type"
    t.text     "sales_amount"
    t.text     "invoice_remark"
    t.text     "item_name"
    t.text     "item_count"
    t.text     "item_word"
    t.text     "item_price"
    t.text     "item_tax_type"
    t.text     "item_amount"
    t.text     "inv_type"
    t.text     "inv_create_date"
    t.text     "vat"
    t.text     "invoice_number"
    t.text     "status"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

end
