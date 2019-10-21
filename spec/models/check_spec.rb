require "rails_helper"

RSpec.describe Check, type: :model do
  it "should not permit changes after creation" do
    claim = create(:claim, :submitted)
    check = Check.create!(claim: claim, checked_by: "123", result: :approved)

    expect { check.update(checked_by: "456") }.to raise_error(ActiveRecord::ReadOnlyRecord)

    expect(check.reload.checked_by).to eq("123")
  end

  it "validates the check has a result" do
    expect(build(:check, result: "approved")).to be_valid
    expect(build(:check, result: nil)).not_to be_valid
  end
end
