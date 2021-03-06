class SIADE::EntrepriseAdapter
  def initialize(siren)
    @siren = siren
  end

  def data_source
    @data_source ||= JSON.parse(SIADE::API.entreprise(@siren), symbolize_names: true)
  rescue
    @data_source = nil
  end

  def success?
    data_source
  rescue
    false
  end

  def to_params
    params = data_source[:entreprise].slice(*attr_to_fetch)
    params[:date_creation] = Time.at(params[:date_creation]).to_datetime
    params
  rescue
    nil
  end

  private

  def attr_to_fetch
    [
      :siren,
      :capital_social,
      :numero_tva_intracommunautaire,
      :forme_juridique,
      :forme_juridique_code,
      :mandataires_sociaux,
      :nom_commercial,
      :raison_sociale,
      :siret_siege_social,
      :code_effectif_entreprise,
      :date_creation,
      :nom,
      :prenom
    ]
  end
end
