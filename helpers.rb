SMTP = {
  address: 'smtp.sendgrid.net',
  port: '25',
  user_name: ENV['SENDGRID_USERNAME'],
  password: ENV['SENDGRID_PASSWORD'],
  authentication: :plain
}    

BBLOG_ADMIN = 'no-reply@bblog'
TIME_FORMAT = 'UTC %l:%M %p'
DATE_FORMAT = '%d-%b-%Y'
DATETIME_FORMAT = 'UTC %k:%M, %d-%b-%y'

ADMIN = "Basic Blog Notification<do_not_reply@bblog>"
BBLOG_TO = "admin@bblog"

module Security
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def encrypt(user, plaintext_password, salt)
    secure_digest(user, plaintext_password, salt)
  end

  def make_token
    generate_uuid
  end  

  def make_temporary_password
    secure_digest(Time.now, (1..5).map{ rand.to_s })[0..8]
  end

  def generate_uuid
    SecureRandom.uuid
  end
  
end

module Web
  def require_login      
    redirect "/login" unless session[:user]
    sess = Session[uuid: session[:user]]
    @user = sess.user
  end
  
  def snippet(page, options={})
    haml page, options.merge!(layout: false)
  end

  def markdown(content)
    if content
      Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true), 
        { 
          autolink: true, 
          space_after_headers: true,
          no_intra_emphasis: true,
          superscript: true,
          underline: true,
          highlight: true,
          quote: true,
          tables: true
        }
      ).render(content)
    else
      ""
    end
  end        
  
end



module Comms
  class SmtpApiHeader

    def initialize
      @data = {}
    end

    def add_to(to)
      @data['to'] ||= []
      @data['to'] += to.kind_of?(Array) ? to : [to]
    end

    def add_sub_val(var, val)
      if not @data['sub']
        @data['sub'] = {}
      end
      if val.instance_of?(Array)
        @data['sub'][var] = val
      else
        @data['sub'][var] = [val]
      end
    end

    def set_unique_args(val)
      if val.instance_of?(Hash)
        @data['unique_args'] = val
      end
    end

    def set_category(cat)
      @data['category'] = cat
    end

    def add_filter_setting(fltr, setting, val)
      if not @data['filters']
        @data['filters'] = {}
      end
      if not @data['filters'][fltr]
        @data['filters'][fltr] = {}
      end
      if not @data['filters'][fltr]['settings']
        @data['filters'][fltr]['settings'] = {}
      end
      @data['filters'][fltr]['settings'][setting] = val
    end

    def as_json
      json = JSON.generate @data
      return json.gsub(/(["\]}])([,:])(["\[{])/, '\\1\\2 \\3')
    end

    def as_string
      json  = as_json
      str = 'X-SMTPAPI: %s' % json.gsub(/(.{1,72})( +|$\n?)|(.{1,72})/,"\\1\\3\n")
      return str
    end

  end
  
  def setup_mail
    Pony.options = {to: BBLOG_TO, from: ADMIN, via: :smtp, via_options: SMTP}
  end
  
  def send_mail(sender, recipient, subject, html_body, attachment=nil, attachment_filename=nil)  
    Pony.options = {from: sender, via: :smtp, via_options: SMTP}
    if attachment
      Pony.mail to: recipient, subject: subject, html_body: html_body, attachments: {attachment_filename => attachment}      
    else      
      Pony.mail to: recipient, subject: subject, html_body: html_body
    end
  end

end