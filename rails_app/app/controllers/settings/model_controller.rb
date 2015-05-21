class Settings::ModelController < Settings::CustomerController
  def model
    RefModel
  end

  def projects
    rf = model.arel_table
    {
      "record_id"         => rf[:id],
      "lock_version"      => rf[:lock_version],
      "model_name"        => rf[:model_name],
      "remark"            => rf[:remark]
    }
  end

  def index_list result
    rf = model.arel_table

    stmt = rf.project(project_stmt projects).where(rf[:deleted_at].eq nil).order(rf[:model_name])

    stmt.where(rf[:model_name].matches "%#{params[:model_name]}%") unless params[:model_name].blank?
    stmt.where(rf[:remark].matches "%#{params[:remark]}%") unless params[:remark].blank?

    result[:rows] = result_rows stmt, projects
    result[:total] = result_total stmt
  end
end
