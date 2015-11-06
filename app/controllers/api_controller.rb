class ApiController < ApplicationController
  PRE_ENCODE_COLUMN = [:CustomerName, :CustomerAddr , :CustomerEmail, :InvoiceRemark, :ItemName, :ItemWord, :InvCreateDate]
  BLACK_LIST_COLUMN = [:ItemName, :ItemWord, :InvoiceRemark, :Reason]
  DEVELOP_ENVIRONMENT = {
      HOST: 'http://einvoice-stage.allpay.com.tw/Invoice/',
      HashKey: 'ejCk326UnaZWKisg',
      HashIV: 'q9jcZX8Ib9LM8wYk',
      MerchantID: '2000132'
  }

  def index
  end

  def issue
    data = {
        TimeStamp: Time.now().to_i,
        MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
        RelateNumber: SecureRandom.hex(15),
        CustomerEmail: 'abc@allpay.com.tw',
        Print: '0',
        Donation: '2',
        TaxType: '1',
        SalesAmount: 300,
        ItemName: '名稱 1|名稱 2|名稱 3',
        ItemCount: '1|2|3',
        ItemWord: '單位 1|單位 2|單位 3',
        ItemPrice: '44|55|66',
        ItemAmount: '100|100|100',
        InvType: '07',
        InvCreateDate: Time.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    data = generate_check_mac_value(data)
    send_request('Issue', data)

    render "result.html.erb"
  end

  def delay_issue
    data = {
        TimeStamp: Time.now().to_i,
        DelayFlag: 1,
        MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
        RelateNumber: SecureRandom.hex(15),
        CustomerEmail: 'abc@allpay.com.tw',
        TaxType: '1',
        Donation: '2',
        Print: '0',
        SalesAmount: 300,
        ItemName: '名稱 1|名稱 2|名稱 3',
        ItemCount: '1|2|3',
        ItemWord: '單位 1|單位 2|單位 3',
        ItemPrice: '44|55|66',
        ItemAmount: '100|100|100',
        DelayDay: '7',
        Tsr: SecureRandom.hex(15),
        PayType: '3',
        PayAct: 'ALLPAY',
        InvType: '07'
    }
    data = generate_check_mac_value(data)
    send_request('DelayIssue', data)

    render "result"
  end

  def allowance
    data = {
        TimeStamp: Time.now().to_i,
        MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
        InvoiceNo: 'AL00000615',
        AllowanceNotify: 'E',
        NotifyMail: 'abc@allpay.com.tw',
        AllowanceAmount: 50,
        ItemName: '名稱 1|名稱 2|名稱 3',
        ItemCount: '1|2|3',
        ItemWord: '單位 1|單位 2|單位 3',
        ItemPrice: '44|55|65',
        ItemAmount: '100|100|100'
    }
    data = generate_check_mac_value(data)
    send_request('Allowance', data)

    render "result"
  end

  def issue_invalid
    data = {
        TimeStamp: Time.now().to_i,
        MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
        InvoiceNumber: 'AL00000614',
        Reason: 'I hate test.'
    }
    data = generate_check_mac_value(data)
    send_request('IssueInvalid', data)

    render "result"
  end

  def allowance_invalid
    data = {
        TimeStamp: Time.now().to_i,
        MerchantID: DEVELOP_ENVIRONMENT[:MerchantID],
        InvoiceNo: 'AL00000614',
        AllowanceNo: 'Allpay0123456789',
        Reason: 'I hate test.'
    }
    data = generate_check_mac_value(data)
    send_request('IssueInvalid', data)

    render "result"
  end

  private

  def generate_check_mac_value(data)
    str = ''
    (data.keys - BLACK_LIST_COLUMN).sort.each do |key|
      value = PRE_ENCODE_COLUMN.include?(key) ? CGI::escape(data[key].to_s) : data[key]
      str += "#{key}=#{value}&"
    end
    str = "HashKey=#{DEVELOP_ENVIRONMENT[:HashKey]}&#{str}HashIV=#{DEVELOP_ENVIRONMENT[:HashIV]}"
    data[:CheckMacValue] = Digest::MD5.hexdigest(CGI::escape(str).downcase).upcase
    data
  end

  def send_request(action_name, data)
    uri = URI(DEVELOP_ENVIRONMENT[:HOST] << action_name)
    result = Net::HTTP.post_form(uri, data)
    logger.info "== #{result} =="
    logger.info "== #{result.body} =="

    obj = {}
    result.body.split('&').each do |item|
      key, value = item.split('=')
      obj[key] = value
    end

    @data = data
    @result = obj
    @error_msg = error_msg(obj["RtnCode"])
  end

  def error_msg(code)
    error_msgs = {
        "1" => "成功.",
        "1000000" => "timestamp 檢查錯誤",
        "1000001" => "計算回傳檢核碼失敗",
        "1000002" => "查詢開立發票失敗",
        "1000003" => "查詢作廢發票失敗",
        "1000004" => "執行時期錯誤",
        "1000005" => "自定錯誤訊息",
        "10100050" => "Parameter Error.(參數錯誤)",
        "10200073" => "CheckMacValue Error.(檢查碼錯誤)",
        "10200074" => "找不到加密金鑰，請確認是否有申請開通此付款方式",
        "10200090" => "CheckMacValue is null.(CheckMacValue 不得為空白)",
        "1200000" => "查無公司資料",
        "1200001" => "無通關方式資料或通關方式代碼錯誤",
        "1200002" => "商品明細資料格式不正確",
        "1200003" => "無商品名稱",
        "1200004" => "商品名稱字數過長",
        "1200005" => "無商品數量",
        "1200006" => "商品數量格式錯誤",
        "1200007" => "商品數量超過 5 位數限制",
        "1200008" => "無商品單位",
        "1200009" => "商品單位名稱字數過長",
        "1200010" => "無商品價格",
        "1200011" => "商品價格格式錯誤",
        "1200012" => "商品價格超過 8 位數限制",
        "1200013" => "無商品合計金額",
        "1200014" => "商品合計金額格式錯誤",
        "1200015" => "商品合計金額超過 12 位數限制",
        "1200016" => "無自訂編號",
        "1200017" => "自訂編號只接受英、數字與下底線格式",
        "1200018" => "客戶統一編號格式不正確，請確認",
        "1200019" => "無客戶編號",
        "1200020" => "客戶編號只接受英、數字與下底線格式",
        "1200021" => "列印發票時，客戶(買受人)名稱須有值",
        "1200022" => "客戶(買受人)名稱僅能為中英數字格式",
        "1200023" => "列印發票時，買受人地址須有值",
        "1200024" => "客戶(買受人)電子信箱及手機號碼不可同時為空白",
        "1200025" => "客戶(買受人)電子信箱格式錯誤",
        "1200026" => "客戶(買受人)市內電話或手機號碼格式錯誤",
        "1200027" => "請選擇課稅類別或課稅類別代碼錯誤",
        "1200028" => "發票金額錯誤",
        "1200029" => "發票金額格式錯誤",
        "1200030" => "發票金額超過限制金額長度 12 位數",
        "1200031" => "驗證發票金額發現錯誤，與商品合計金額不符",
        "1200032" => "列印註記代碼錯誤",
        "1200033" => "您已選擇捐贈發票，需輸入愛心碼或選擇受捐單位",
        "1200034" => "無效的愛心碼",
        "1200035" => "您已選擇捐贈發票，不能索取紙本發票",
        "1200036" => "請選擇載具類別或載具類別代碼錯誤",
        "1200037" => "請於「載具編號」填寫買受人之自然人憑證號碼",
        "1200038" => "請於「載具編號」填寫買受人之手機條碼資料",
        "1200039" => "已填寫統一編號，只能選擇列印紙本發票",
        "1200040" => "已填寫統一編號，無法捐贈發票",
        "1200041" => "已填寫統一編號，載具類別不可為會員或自然人憑證載具",
        "1200042" => "無效的自然人憑證",
        "1200043" => "無效的手機條碼",
        "1200044" => "手機條碼驗證失敗",
        "1200045" => "開立發票失敗(無效的發票類別)",
        "1200046" => "開立發票失敗(自訂編號重覆，請重新設定)",
        "1200047" => "開立發票失敗(查無可使用字軌發票)",
        "1200048" => "開立發票失敗(無法取得發票號碼)",
        "1200049" => "開立發票失敗(執行時期錯誤)",
        "1200050" => "欄位格式錯誤",
        "1200051" => "無匯入單號",
        "1200052" => "無效的匯入單號",
        "1200053" => "無捐贈註記",
        "1200054" => "無效的捐贈註記代碼",
        "1200055" => "無內容的發票檔",
        "1200056" => "檔案大小超過 2MB",
        "1200057" => "載入發票檔失敗",
        "1200058" => "遺漏發票基本資料(該列資料可能為商品明細)",
        "1200059" => "匯入單號重覆",
        "1200060" => "自訂編號超過 30 位數限制",
        "1200061" => "客戶編號超過 20 位數限制",
        "1200062" => "客戶姓名超過 30 位數限制",
        "1200063" => "發票類別錯誤",
        "1200064" => "無開立混合稅率發票的權限",
        "1200065" => "無商品課稅別",
        "1200066" => "商品課稅別代碼錯誤",
        "1200067" => "開立混合稅率發票字軌類別限收銀機發票",
        "1200068" => "無效的發票類別(混合稅率發票字軌類別限收銀機發票)",
        "1200069" => "傳入的開立日期時間格式不正確",
        "1200070" => "傳入的開立日期時間僅能為前 48 小時以內",
        "1200071" => "二聯式發票不得輸入統一編號",
        "1200072" => "客戶地址超過 100 位數限制",
        "1200073" => "已選擇列印紙本發票，載具類別需空白",
        "1200074" => "商品內含稅設定格式錯誤",
        "1600000" => "發票號碼不可為空白",
        "1600001" => "無發票作廢原因",
        "1600002" => "發票作廢原因須在 20 字以內",
        "1600003" => "無發票號碼資料",
        "1600004" => "該發票已過可作廢日期",
        "1600005" => "作廢發票失敗(該發票已被折讓過，無法直接作廢發票並請確認 該發票所開立的折讓單是否全部已作廢)",
        "1600006" => "作廢發票失敗(該發票已被作廢過)",
        "1600007" => "作廢發票失敗(無法新增)",
        "1600008" => "作廢發票失敗(執行時期錯誤)",
        "1600009" => "自訂編號不可為空白",
        "1600010" => "作廢發票失敗(該發票已被註銷過，無法作廢發票)",
        "1600011" => "作廢發票失敗(該發票上傳失敗，無法作廢發票)",
        "1800000" => "無效的延遲註記",
        "1800001" => "無延遲天數或格式錯誤",
        "1800002" => "若為延遲開立時，則延遲天數須介於 1 至 15 天內",
        "1800003" => "若為觸發開立時，則延遲天數須介於 0 至 15 天內",
        "1800004" => "無交易單號或長度大於 30",
        "1800005" => "無效的交易類別",
        "1800006" => "無效的交易類別名稱",
        "1800007" => "無通知 URL",
        "1800008" => "開立延遲(或觸發)發票失敗(交易單號重覆，請重新設定)",
        "1800009" => "開立延遲(或觸發)發票失敗(新增失敗)",
        "1800010" => "開立{0}發票失敗(執行時期錯誤)",
        "2000001" => "timestamp 檢查錯誤",
        "2000002" => "發票號碼格式錯誤",
        "2000003" => "客戶(買受人)名稱僅能為中英數字格式",
        "2000004" => "無勾選通知方式",
        "2000005" => "請填寫電子信箱或手機號碼",
        "2000006" => "您選擇手機簡訊為通知方式，但未填寫手機號碼!",
        "2000007" => "您選擇電子信箱為通知方式，但未填寫電子信箱!",
        "2000008" => "請填寫電子信箱及手機號碼",
        "2000009" => "無勾選通知方式",
        "2000010" => "電子信箱格式錯誤",
        "2000011" => "手機號碼格式錯誤",
        "2000012" => "折讓發票金額格式錯誤",
        "2000013" => "折讓商品明細 - 無商品第 1 列名稱",
        "2000014" => "折讓商品明細 - 商品第 1 列數量錯誤",
        "2000015" => "折讓商品明細 - 無商品第 1 列單位錯誤",
        "2000016" => "折讓商品明細 - 商品第 1 列單價錯誤",
        "2000017" => "折讓商品明細 - 商品第 1 列合計金額錯誤",
        "2000018" => "無該筆發票資料!",
        "2000019" => "商品明細資料錯誤",
        "2000020" => "折讓商品明細 - 無商品第 n 列名稱",
        "2000021" => "折讓商品明細 - 商品第 n 列數量錯誤",
        "2000022" => "折讓商品明細 - 商品第 n 列數量格式錯誤",
        "2000023" => "折讓商品明細 - 商品第 n 列數量不得為 0",
        "2000024" => "折讓商品明細 - 商品第 n 列數量超過限制",
        "2000025" => "折讓商品明細 - 無商品第 n 列單位",
        "2000026" => "折讓商品明細 - 無商品第 n 列單價錯誤",
        "2000027" => "折讓商品明細 - 商品第 n 列單價格式錯誤",
        "2000028" => "折讓商品明細 - 商品第 n 列單價不得為 0",
        "2000029" => "折讓商品明細 - 商品第 n 列單價金額超過限制",
        "2000030" => "折讓商品明細 - 商品第 n 列合計金額錯誤",
        "2000031" => "折讓商品明細 - 商品第 n 列合計金額計算錯誤",
        "2000032" => "折讓商品明細 - 商品第 n 列合計金額超過限制",
        "2000033" => "驗證折讓發票金額發現錯誤，與折讓商品合計金額不符",
        "2000034" => "無足夠金額可以折讓，請確認",
        "2000035" => "該發票可折讓的金額已經為 0 元，無法折讓，請確認!",
        "2000036" => "查無公司資料",
        "2000037" => "折讓單單號格式錯誤",
        "2000038" => "無折讓單作廢原因",
        "2000039" => "查無折讓單資料，請確認!",
        "2000040" => "MerchantID Error",
        "2000041" => "該折讓單已過可作廢日期",
        "2000042" => "作廢發票號碼不能折讓",
        "2000043" => "折讓單作廢原因須在 20 字以內",
        "2000044" => "客戶姓名超過 20 位數限制",
        "2000045" => "查無折讓單作廢資料，請確認!",
        "2000046" => "折讓發票失敗(該發票已被註銷過，無法折讓發票)",
        "2000047" => "折讓作廢失敗(發票已被註銷過，無法折讓作廢)",
        "2000048" => "折讓商品明細 - 商品課稅別代碼錯誤",
        "2000049" => "折讓發票失敗(該發票上傳失敗，無法折讓發票)",
        "2000050" => "折讓單作廢失敗(該折讓單上傳失敗，無法作廢折讓單)",
        "2000051" => "折讓商品明細 - 商品第 n 列單位長度超過限制",
        "3" => "成功.",
        "3000001" => "發送對象錯誤",
        "3000002" => "查無發票中獎資料，請確認!",
        "3000003" => "發送通知類型錯誤",
        "4000001" => "不存在此交易單號",
        "4000002" => "呼叫開立發票 API 失敗",
        "4000003" => "延後開立成功",
        "4000004" => "開立發票成功",
        "4000005" => "交易類型錯誤",
        "4000006" => "交易單號錯誤"
    }
    error_msgs[code]
  end

end