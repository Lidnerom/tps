class Admin::ProceduresController < ApplicationController
  before_action :authenticate_administrateur!

  def index
    @procedures = Procedure.all
  end

  def show
    @procedure = Procedure.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash.alert = 'Procédure inéxistante'
    redirect_to admin_procedures_path
  end

  def new
    @procedure ||= Procedure.new
  end

  def create
    @procedure = Procedure.new

    @procedure.libelle = params[:procedure][:libelle]
    @procedure.description = params[:procedure][:description]
    @procedure.organisation = params[:procedure][:organisation]
    @procedure.direction = params[:procedure][:direction]
    @procedure.lien_demarche = params[:procedure][:lien_demarche]
    @procedure.use_api_carto = params[:procedure][:use_api_carto]

    unless @procedure.save
      flash.now.alert = @procedure.errors.full_messages.join('<br />').html_safe
      return render 'new'
    end

    process_types_de_champs_params
    process_types_de_piece_justificative_params

    flash.notice = 'Procédure enregistrée'

    redirect_to admin_procedures_path
  end

  def update
    @procedure = Procedure.find(params[:id])

    unless @procedure.update_attributes(create_procedure_params)
      flash.now.alert = @procedure.errors.full_messages.join('<br />').html_safe
      return render 'show'
    end

    process_types_de_champs_params
    process_types_de_piece_justificative_params

    flash.notice = 'Préocédure modifiée'
    redirect_to admin_procedures_path

  # rescue ActiveRecord::RecordNotFound
  #   flash.alert = 'Procédure inéxistante'
  #   redirect_to admin_procedures_path
  end

  private

  def process_types_de_champs_params
    unless params[:type_de_champs].nil? || params[:type_de_champs].size == 0
      params[:type_de_champs].each do |index, type_de_champs|

        if type_de_champs[:delete] == 'true'
          unless type_de_champs[:id_type_de_champs].nil? || type_de_champs[:id_type_de_champs] == ''
            TypeDeChamps.destroy(type_de_champs[:id_type_de_champs])
          end
        else
          if type_de_champs[:id_type_de_champs].nil? || type_de_champs[:id_type_de_champs] == ''
            bdd_object = TypeDeChamps.new
          else
            bdd_object = TypeDeChamps.find(type_de_champs[:id_type_de_champs])
          end

          save_type_de_champs bdd_object, type_de_champs
        end
      end
    end
  end

  def process_types_de_piece_justificative_params
    unless params[:type_de_piece_justificative].nil? || params[:type_de_piece_justificative].size == 0
      params[:type_de_piece_justificative].each do |index, type_de_piece_justificative|

        if type_de_piece_justificative[:delete] == 'true'
          unless type_de_piece_justificative[:id_type_de_piece_justificative].nil? || type_de_piece_justificative[:id_type_de_piece_justificative] == ''
            TypeDePieceJustificative.destroy(type_de_piece_justificative[:id_type_de_piece_justificative])
          end
        else
          if type_de_piece_justificative[:id_type_de_piece_justificative].nil? || type_de_piece_justificative[:id_type_de_piece_justificative] == ''
            bdd_object = TypeDePieceJustificative.new
          else
            bdd_object = TypeDePieceJustificative.find(type_de_piece_justificative[:id_type_de_piece_justificative])
          end

          save_type_de_piece_justificative bdd_object, type_de_piece_justificative
        end
      end
    end
  end

  def save_type_de_champs database_object, source
    database_object.libelle = source[:libelle]
    database_object.type_champs = source[:type]
    database_object.description = source[:description]
    database_object.order_place = source[:order_place]
    database_object.procedure = @procedure

    database_object.save
  end

  def save_type_de_piece_justificative database_object, source
    database_object.libelle = source[:libelle]
    database_object.description = source[:description]
    database_object.procedure = @procedure

    database_object.save
  end

  def create_procedure_params
    params.require(:procedure).permit(:libelle, :description, :organisation, :direction, :lien_demarche, :use_api_carto)
  end
end