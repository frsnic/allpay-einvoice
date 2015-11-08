class EinvoicesController < ApplicationController
  before_action :find_einvoice, except: [:index, :new, :issue]

=begin
  PRE_ENCODE_COLUMN = [:CustomerName, :CustomerAddr , :CustomerEmail, :InvoiceRemark, :ItemName, :ItemWord, :InvCreateDate, :NotifyMail]
  BLACK_LIST_COLUMN = [:ItemName, :ItemWord, :InvoiceRemark, :Reason]
  DEVELOP_ENVIRONMENT = {
      HOST: 'http://einvoice-stage.allpay.com.tw/',
      HashKey: 'ejCk326UnaZWKisg',
      HashIV: 'q9jcZX8Ib9LM8wYk',
      MerchantID: '2000132'
  }
=end

  def index
    @einvoices = Einvoice.all
  end

  def new
    @einvoice = Einvoice.new
  end

  def show
  end

  def edit
  end

  def notify
  end

  def issue
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      RelateNumber: SecureRandom.hex(15),
      Print: '0',
      Donation: '2',
      TaxType: '1',
      SalesAmount: 300,
      InvType: '07',
      InvCreateDate: Time.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    data[:CustomerEmail] = params[:einvoice][:customer_email]
    data[:CustomerPhone] = params[:einvoice][:customer_phone]
    data[:ItemName]      = params[:einvoice][:item_name]
    data[:ItemCount]     = params[:einvoice][:item_count]
    data[:ItemWord]      = params[:einvoice][:item_word]
    data[:ItemPrice]     = params[:einvoice][:item_price]
    data[:ItemAmount]    = item_amount(data)
    data[:SalesAmount]   = sales_amount(data)
    encode_data          = encode_and_check_mac_value(data)
    send_request('Invoice/Issue', encode_data)

    if (@result["RtnCode"] == "1")
      obj = {"invoice_number" => @result["InvoiceNumber"], status: 'issue'}
      data.each { |key, value| obj[key.to_s.underscore] = value }
      Einvoice.create(obj)
    end

    render "result.html.erb"
  end

  def issue_invalid
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      InvoiceNumber: @einvoice.invoice_number,
      Reason: 'I hate test.'
    }
    data = encode_and_check_mac_value(data)
    send_request('Invoice/IssueInvalid', data)

    if (@result["RtnCode"] == "1")
      @einvoice.update!(status: 'issue_invalid')
    end

    render "result"
  end

  def allowance
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      InvoiceNo: @einvoice.invoice_number,
    }
    data[:CustomerName]    = params[:einvoice][:customer_name]
    data[:NotifyMail]      = params[:einvoice][:customer_email]
    data[:NotifyPhone]     = params[:einvoice][:customer_phone]
    data[:AllowanceNotify] = notify_type(params[:einvoice][:customer_email], params[:einvoice][:customer_phone])
    data[:ItemName]        = params[:einvoice][:item_name]
    data[:ItemCount]       = params[:einvoice][:item_count]
    data[:ItemWord]        = params[:einvoice][:item_word]
    data[:ItemPrice]       = params[:einvoice][:item_price]
    data[:ItemAmount]      = item_amount(data)
    data[:AllowanceAmount] = sales_amount(data)
    data                   = encode_and_check_mac_value(data)
    send_request('Invoice/Allowance', data)

    if (@result["RtnCode"] == "1")
      obj = {status: "allowance"}
      @result.except("RtnCode", "RtnMsg", "CheckMacValue").keys.each { |key| obj[key.downcase] = @result[key] }
      @einvoice.credit_notes.create!(obj)
      @einvoice.update!(status: 'allowance')
    end

    render "result"
  end

  def query_issue
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      RelateNumber: @einvoice.relate_number
    }
    data = encode_and_check_mac_value(data)
    send_request('Query/Issue', data)

    render "result"
  end

  def query_issue_invalid
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      RelateNumber: @einvoice.relate_number
    }
    data = encode_and_check_mac_value(data)
    send_request('Query/IssueInvalid', data)

    render "result"
  end

  def invoice_notify
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      InvoiceNo: @einvoice.invoice_number,
    }
    data[:AllowanceNo] = params[:form][:allowance_no]
    data[:Phone]       = params[:form][:phone]
    data[:NotifyMail]  = params[:form][:notify_mail]
    data[:Notify]      = notify_type(params[:form][:notify_mail], params[:form][:phone])
    data[:InvoiceTag]  = params[:form][:invoice_tag]
    data[:Notified]    = params[:form][:notified]
    data               = encode_and_check_mac_value(data)
    send_request('Notify/InvoiceNotify', data)

    render "result"
  end

  def delay_issue
    data = {
      TimeStamp: Time.now().to_i,
      DelayFlag: 2,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      RelateNumber: "fb8532344305c47c5302d5e0ec2d52",
      CustomerEmail: 'frsnic@gmail.com',
      TaxType: '1',
      Donation: '2',
      Print: '0',
      SalesAmount: 300,
      ItemName: '名稱 1|名稱 2|名稱 3',
      ItemCount: '1|2|3',
      ItemWord: '單位 1|單位 2|單位 3',
      ItemPrice: '44|55|66',
      ItemAmount: '100|100|100',
      DelayDay: '0',
      Tsr: SecureRandom.hex(15),
      PayType: '3',
      PayAct: 'ALLPAY',
      InvType: '07'
    }
    data = encode_and_check_mac_value(data)
    send_request('Invoice/DelayIssue', data)

    render "result"
  end

  def trigger_issue
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      Tsr: SecureRandom.hex(15),
      PayType: '3'
    }
    data = generate_check_mac_value(data)
    send_request('Invoice/TriggerIssue', data)

    render "result"
  end

  private

  def find_einvoice
    @einvoice = Einvoice.find(params[:id])
  end

  def item_amount(data)
    items_count  = data[:ItemCount].split('|')
    items_price  = data[:ItemPrice].split('|')
    items_amount = []
    items_count.each_with_index { |item, i| items_amount << (item.to_i * items_price[i].to_i) }
    items_amount.join("|")
  end

  def sales_amount(data)
    data[:ItemAmount].split("|").collect{ |item| item.to_i }.sum
  end

end
