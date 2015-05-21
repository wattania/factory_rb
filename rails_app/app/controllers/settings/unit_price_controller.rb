class Settings::UnitPriceController < Settings::CustomerController
  def model
    RefUnitPrice
  end

  def projects
    rf = model.arel_table
    {
      "record_id"         => rf[:id],
      "lock_version"      => rf[:lock_version],
      "unit_name"         => rf[:unit_name],
      "remark"            => rf[:remark]
    }
  end

  def index_list result
    rf = model.arel_table

    stmt = rf.project(project_stmt projects).where(rf[:deleted_at].eq nil).order(rf[:unit_name])

    stmt.where(rf[:unit_name].matches "%#{params[:unit_name]}%") unless params[:unit_name].blank?
    stmt.where(rf[:remark].matches "%#{params[:remark]}%") unless params[:remark].blank?

    result[:rows] = result_rows stmt, projects
    result[:total] = result_total stmt
  end
end
