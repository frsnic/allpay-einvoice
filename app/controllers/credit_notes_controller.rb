class CreditNotesController < ApplicationController
  before_filter :find_einvoice
  before_filter :find_credit_note, except: [:index]

  def index
    @credit_notes = @einvoice.credit_notes
  end

  def show
  end

  def allowance_invalid
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      InvoiceNo: @credit_note.ia_invoice_no,
      AllowanceNo: @credit_note.ia_allow_no,
      Reason: 'I hate test.'
    }
    data = encode_and_check_mac_value(data)
    send_request('Invoice/AllowanceInvalid', data)

    if (@result[:RtnCode] == "1")
      @credit_note.update!(status: "allowance_invalid")
      if @einvoice.credit_notes.pluck(:status).uniq == ["allowance_invalid"]
        @einvoice.update!(status: "issue")
      end
    end

    render "einvoices/result"
  end

  def query_allowance
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      InvoiceNo: @credit_note.ia_invoice_no,
      AllowanceNo: @credit_note.ia_allow_no
    }
    data = encode_and_check_mac_value(data)
    send_request('Query/Allowance', data)

    render "einvoices/result"
  end

  def query_allowance_invalid
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
      InvoiceNo: @credit_note.ia_invoice_no,
      AllowanceNo: @credit_note.ia_allow_no
    }
    data = encode_and_check_mac_value(data)
    send_request('Query/AllowanceInvalid', data)

    render "einvoices/result"
  end

  private

  def find_einvoice
    @einvoice = Einvoice.find(params[:einvoice_id])
  end

  def find_credit_note
    @credit_note = CreditNote.find(params[:id])
  end

end
