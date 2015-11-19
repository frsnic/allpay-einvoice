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
    obj = {}
    data.each_pair { |key, value| obj[key.downcase] = value }
    str = (obj.keys - BLACK_LIST_COLUMN.map(&:downcase)).sort.inject('') { |str, key| str << "#{key}=#{obj[key]}&" }
    str = "HashKey=#{DEVELOP_ENVIRONMENT[:HashKey]}&#{str}HashIV=#{DEVELOP_ENVIRONMENT[:HashIV]}"
    str = CGI::escape(str).gsub("%21","!").gsub("%2A","*").gsub("%28","(").gsub("%29",")")
    Digest::MD5.hexdigest(str.downcase).upcase
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
    uri = URI(DEVELOP_ENVIRONMENT[:HOST] + url)
    result = Net::HTTP.post_form(uri, data)
    logger.info "== #{result.body} =="

    obj = {}
    result.body.split('&').each do |item|
      key, value = item.split('=')
      key = key.to_sym
      obj[key] = value
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
