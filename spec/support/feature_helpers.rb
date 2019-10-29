module FeatureHelpers
  def answer_all_student_loans_claim_questions
    start_claim
    choose_school schools(:penistone_grammar_school)
    choose_still_teaching "Yes, at another school"
    choose_school schools(:hampstead_school)
    choose_subjects_taught
    click_on "Continue"

    perform_verify_step
    click_on "Continue"

    fill_in :claim_teacher_reference_number, with: "1234567"
    click_on "Continue"

    fill_in "National Insurance number", with: "QQ123456C"
    click_on "Continue"

    answer_student_loan_plan_questions
    fill_in I18n.t("student_loans.questions.student_loan_amount", claim_school_name: claim.eligibility.claim_school_name), with: "1100"
    click_on "Continue"

    fill_in I18n.t("questions.email_address"), with: "name@example.tld"
    click_on "Continue"

    fill_in "Name on the account", with: "Jo Bloggs"
    fill_in "Sort code", with: "123456"
    fill_in "Account number", with: "87654321"
    click_on "Continue"
  end

  def start_claim
    visit new_claim_path
    choose_qts_year
    Claim.order(:created_at).last
  end

  def choose_qts_year(year = "On or after 1 September 2013")
    choose year
    click_on "Continue"
  end

  def choose_school(school)
    fill_in :school_search, with: school.name.sub("The ", "").split(" ").first
    click_on "Search"

    choose school.name
    click_on "Continue"
  end

  def choose_still_teaching(teaching_at = "Yes, at Penistone Grammar School")
    choose teaching_at
    click_on "Continue"
  end

  def choose_subjects_taught
    check "Physics"
    click_on "Continue"

    choose "Yes"
    click_on "Continue"

    choose "No"
    click_on "Continue"
  end

  def perform_verify_step(response_type = "identity-verified")
    stub_vsp_generate_request
    stub_vsp_translate_response_request(response_type)

    click_on "Continue"
    # non-JS means we need to manually submit the /verify/authentications/new form
    click_on "Continue" unless Capybara.current_driver == Capybara.javascript_driver
    # Submit the form generated by our FakeSso
    click_on "Perform identity check"
  end

  def fill_in_date_of_birth
    fill_in "Day", with: "03"
    fill_in "Month", with: "7"
    fill_in "Year", with: "1990"
    click_on "Continue"
  end

  def fill_in_address
    fill_in :claim_address_line_1, with: "123 Main Street"
    fill_in :claim_address_line_2, with: "Downtown"
    fill_in "Town or city", with: "Twin Peaks"
    fill_in "County", with: "Washington"
    fill_in "Postcode", with: "M1 7HL"
    click_on "Continue"
  end

  def answer_student_loan_plan_questions
    choose("Yes")
    click_on "Continue"
    choose("England")
    click_on "Continue"
    choose("1")
    click_on "Continue"
    choose I18n.t("answers.student_loan_start_date.one_course.before_first_september_2012")
    click_on "Continue"
  end

  def sign_in_to_admin_with_role(*args)
    stub_dfe_sign_in_with_role(*args)
    visit admin_root_path
    click_on "Sign in"
  end

  def wait_until_visible(&block)
    page.document.synchronize do
      element = yield
      raise Capybara::ElementNotFound unless element.visible?
    end
  end
end
