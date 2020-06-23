class Admin::Frameworks::ReportsController < AdminController
  def users
    send_file csv_file, type: 'text/csv', filename: csv_filename
  end

  private

  def framework
    @framework ||= Framework.find(params[:framework_id])
  end

  def short_name
    framework.short_name.downcase.tr('/.', '_')
  end

  def csv_file
    Tempfile.new.tap do |file|
      Export::FrameworkUsers.new(
        Export::FrameworkUsers::Extract.all_relevant(framework),
        file
      ).run

      file.rewind
    end
  end

  def csv_filename
    "framework_#{short_name}_users-#{current_date}.csv"
  end

  def current_date
    Time.zone.today
  end
end
