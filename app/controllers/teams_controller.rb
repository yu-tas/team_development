class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit
    unless current_user == @team.owner
      redirect_to @team, alert: 'チームの編集権限がありません'
      return
    end
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def transfer_ownership
    @team = Team.friendly.find(params[:id])
    new_owner = Assign.find(params[:assign_id]).user

    if @team.owner == current_user
      @team.owner = new_owner
      if @team.save!
         TeamMailer.transfer_ownership_email(new_owner, @team).deliver_later
         redirect_to team_path(@team), notice: '権限が移動されました'
      else
         flash.now[:error] = '権限の移動に失敗しました'
         render :edit
       end
    else
      redirect_to team_path(@team), alert: '権限を移動する権限がありません'
    end
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
