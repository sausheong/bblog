
class SendAccountCreated
  include SuckerPunch::Job, Comms
  
  def perform(email, password)
    subject = "[Blog] Your Blog account has been created"
    data = [email, password]
    template = "./emails/user_account.html"
    eml = File.new template
    html_body = sprintf(eml.read, *data)     
    send_mail(ADMIN, email, subject, html_body)
  end
end

class SendPasswordReset
  include SuckerPunch::Job, Comms
  
  def perform(email, password)
    subject = "[Blog] Your Blog account password has been reset"
    data = [password]
    template = "./emails/password_reset.html"
    eml = File.new template
    html_body = sprintf(eml.read, *data)
    send_mail(ADMIN, email, subject, html_body)
  end
end

class SendMailerSingle
  include SuckerPunch::Job, Comms, Web
  
  def perform(mailer, email)
    job = Job.create job_type: "Send email", user: mailer.user, group: mailer.group
    if mailer.type == "markdown"
      body = markdown(mailer.content)
      setup_mail
      if mailer.attachment
        send_mail(mailer.from_email, email, mailer.subject, body, Base64.decode64(mailer.attachment), mailer.attachment_filename) 
      else
        send_mail(mailer.from_email, email, mailer.subject, body)
      end        
    elsif mailer.type == "image"
      body = ""
    else
      body = ""
    end

    job.update(status: "completed", completed_at: DateTime.now)
  end
  
end
