class Settings::PartController < Settings::CustomerController
  def model
    RefPartName
  end

  def projects
    rf = model.arel_table
    {
      "record_id"         => rf[:id],
      "lock_version"      => rf[:lock_version],
      "part_name"        => rf[:part_name],
      "remark"            => rf[:remark]
    }
  end

  def index_list result
    rf = model.arel_table

    stmt = rf.project(project_stmt projects).where(rf[:deleted_at].eq nil).order(rf[:part_name])

    stmt.where(rf[:part_name].matches "%#{params[:part_name]}%") unless params[:part_name].blank?
    stmt.where(rf[:remark].matches "%#{params[:remark]}%") unless params[:remark].blank?

    result[:rows] = result_rows stmt, projects
    result[:total] = result_total stmt
  end
end