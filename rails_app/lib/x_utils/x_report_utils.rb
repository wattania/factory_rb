class XReportUtils
  def self.get_report_filter a_report_name
    TbBatchReport.__reload_for_dev
    report = ("report_" + a_report_name).camelize.constantize
    return report.get_report_filter()
  end
end