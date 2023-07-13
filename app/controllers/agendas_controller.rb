class AgendasController < ApplicationController
  # before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda') 
    else
      render :new
    end
  end

  def destroy
    @agenda = Agenda.find(params[:id])

    unless current_user.id == @agenda.user_id || current_user.id == @agenda.teams.owner_id
      redirect_to dashboard_path, notice: 'アジェンダはAgendaの作者もしくはそのAgendaに紐づいているTeamの作者（オーナー）しか削除できません'
    return
    end
    @agenda.destroy
    send_agenda_deletion_emails(@agenda)
    redirect_to dashboard_path, notice: 'アジェンダが削除されました'
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end

  def send_agenda_deletion_emails(agenda)
    agenda.team.users.each do |user|
    AgendaMailer.agenda_deleted_emails(user, agenda).deliver_later
    end
  end
end
