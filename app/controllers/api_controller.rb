class ApiController < ApplicationController

  def index
  end

  def send_request
    data = {
      TimeStamp: Time.now().to_i,
      MerchantID: 2000132,
      RelateNumber: '09372378329988',
      CustomerID: 'hahaha_1232',
      CustomerEmail: 'abc%40allpay.com.tw',
      SalesAmount: 1234,
      ItemName: '%E5%90%8D%E7%A8%B11%7C%E5%90%8D%E7%A8%B12%7C%E5%90%8D%E7%A8%B13',
      ItemCount: '1|2|3',
      ItemWord: '%E5%96%AE%E4%BD%8D1%7C%E5%96%AE%E4%BD%8D2%7C%E5%96%AE%E4%BD%8D3',
      ItemPrice: '44|55|66',
      ItemAmount: '100|100|100',
      CheckMacValue: 'csddsdsd',
      InvType: '07',
      InvCreateDate: '2015-08-13+16%3A59%3A11',
    }
    uri = URI('http://einvoice-stage.allpay.com.tw/Invoice/Issue')
    result = Net::HTTP.post_form(uri, data)
    @result = result.body
  end

end
