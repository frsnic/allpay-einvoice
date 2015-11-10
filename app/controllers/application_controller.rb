class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def encode_column(origin_data)
    data = origin_data.clone
    data.keys.each { |key| data[key] = ENCODE_COLUMN.include?(key) ? CGI::escape(data[key].to_s) : data[key] }
    data
  end

  def check_mac_value(data)
    str = (data.keys - BLACK_LIST_COLUMN).sort.inject('') { |str, key| str << "#{key}=#{data[key]}&" }
    logger.info "== str #{str} =="
    str = "HashKey=#{DEVELOP_ENVIRONMENT[:HashKey]}&#{str}HashIV=#{DEVELOP_ENVIRONMENT[:HashIV]}"
    str = str.gsub("%21","!")
             .gsub("%2A","*")
             .gsub("%28","(")
             .gsub("%29",")")
    Digest::MD5.hexdigest(CGI::escape(str).downcase).upcase
  end

  def notify_type(email, phone)
    if email.present? && phone.present?
      return 'A'
    elsif email.present?
      return 'E'
    elsif phone.present?
      return 'S'
    else
      return 'N'
    end
  end

  def send_request(url, data)
    uri = URI(DEVELOP_ENVIRONMENT[:HOST] << url)
    result = Net::HTTP.post_form(uri, data)
    logger.info "== #{result.body} =="

    obj = {}
    result.body.split('&').each do |item|
      key, value = item.split('=')
      obj[key.to_sym] = value
    end

    if !vertify_mac(obj)
      obj[:RtnCode] = -1
      @error_msg = %Q(<span style="color: red">Fake Response</span>)
    else
      @error_msg = URI.decode(result.body).to_s.force_encoding("UTF-8")
    end

    @data = data
    @result = obj
  end

  def vertify_mac(data)
    data[:CheckMacValue] == check_mac_value(data)
  end

end
