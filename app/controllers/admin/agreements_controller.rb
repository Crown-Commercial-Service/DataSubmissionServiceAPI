class Admin::AgreementsController < AdminController
  before_action :load_supplier_agreement_records

  def confirm_activation; end

  def confirm_deactivation; end

  def activate
    @agreement.activate!

    redirect_to [:admin, @supplier], success: "Activated on #{@framework.short_name}"
  end

  def deactivate
    @agreement.deactivate!

    redirect_to [:admin, @supplier], alert: "Deactivated from #{@framework.short_name}"
  end

  private

  def load_supplier_agreement_records
    @supplier = Supplier.find(params[:supplier_id])
    @agreement = @supplier.agreements.find(params[:agreement_id])
    @framework = @agreement.framework
  end
end
