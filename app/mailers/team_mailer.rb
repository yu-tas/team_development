class TeamMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def transfer_ownership_email(user, team)
    @user = user
    @team = team
    mail(to: @user.email, subject: 'You are now the owner of the team')
  end
end