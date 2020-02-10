require "rails_helper"

RSpec.describe "Admin payroll run payments" do
  let(:admin) { create(:dfe_signin_user) }

  before do
    sign_in_to_admin_with_role(DfeSignIn::User::SERVICE_OPERATOR_DFE_SIGN_IN_ROLE_CODE, admin.dfe_sign_in_id)
  end

  let(:payroll_run) { create(:payroll_run, claims_counts: {MathsAndPhysics => 1, StudentLoans => 1}) }
  let(:payment) { payroll_run.payments.first }

  describe "remove" do
    it "shows a confirmation screen" do
      get remove_admin_payroll_run_payment_path(
        payroll_run_id: payroll_run.id,
        id: payment.id
      )

      expect(response.body).to include(payment.id)
      expect(response.body).to include(payment.claims.first.reference)
    end
  end

  describe "destroy" do
    it "deletes a payroll run and shows a message" do
      reference = payment.claims.first.reference

      expect {
        delete admin_payroll_run_payment_path(
          payroll_run_id: payroll_run.id,
          id: payment.id
        )
      }.to change(payroll_run.reload.payments, :count).by(-1)

      expect(payroll_run.payments).to_not include(payment)

      expect(response.body).to include("You have removed a claim from the payroll run")
      expect(response.body).to include(reference)
    end

    it "cannot delete a payment from an already confirmed payroll run" do
      payroll_run.confirmation_report_uploaded_by = admin.id
      payroll_run.save!

      expect {
        delete admin_payroll_run_payment_path(
          payroll_run_id: payroll_run.id,
          id: payment.id
        )
      }.to change(payroll_run.reload.payments, :count).by(0)

      expect(payroll_run.payments).to include(payment)

      expect(response).to redirect_to(admin_payroll_run_path(payroll_run))

      expect(flash[:alert]).to eq("A payment cannot be removed from an already confirmed payroll run")
    end

    it "shows an error if the payment has already been deleted" do
      payment.destroy

      expect {
        delete admin_payroll_run_payment_path(
          payroll_run_id: payroll_run.id,
          id: payment.id
        )
      }.to change(payroll_run.reload.payments, :count).by(0)

      expect(response).to redirect_to(admin_payroll_run_path(payroll_run))

      expect(flash[:alert]).to eq("This payment cannot be found in the payroll run. Maybe you already deleted it?")
    end
  end
end