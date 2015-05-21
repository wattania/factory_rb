class Settings::FreightTermController < Settings::CustomerController
  def model
    RefFreightTerm
  end

  def projects
    rf = RefFreightTerm.arel_table
    {
      "record_id"         => rf[:id],
      "lock_version"      => rf[:lock_version],
      "freight_term"      => rf[:freight_term],
      "remark"            => rf[:remark]
    }
  end

  def index_list result
    rf = model.arel_table

    stmt = rf.project(project_stmt projects).where(rf[:deleted_at].eq nil).order(rf[:freight_term])

    stmt.where(rf[:freight_term].matches "%#{params[:freight_term]}%") unless params[:freight_term].blank?
    stmt.where(rf[:remark].matches "%#{params[:remark]}%") unless params[:remark].blank?

    result[:rows] = result_rows stmt, projects
    result[:total] = result_total stmt
  end
end
