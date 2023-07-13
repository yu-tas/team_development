class AgendaMailer < ApplicationMailer
  def agenda_deleted_emails(user, agenda)
    @user = user
    @agenda = agenda
    mail(to: @user.email, subject: アジェンダが削除されました)
  end
end
