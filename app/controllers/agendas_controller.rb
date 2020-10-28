class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]

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

  #Define Destroy function
  # The author of the agenda or the owner of the team tied to the agenda can remove the agenda.
  def destroy
    if @agenda.user.id == current_user.id || @agenda.team.owner.id == current_user.id
      @agenda.destroy
  #Sending an email to all members of the team to which the agenda belongs when it has been deleted
      DeleteAgendaMailer.delete_agenda_mail(@agenda).deliver
      redirect_to dashboard_path, notice: I18n.t('views.messages.delete_agenda')
    else
      redirect_to dashboard_path, notice: I18n.t('views.messages.cannot_delete_agenda')
    end      
  end
  

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
