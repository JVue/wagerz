require_relative 'biggestbass'

class HTML
  def login_button
    <<~HTML
    <div style="float:right">
    <form method="POST" action="/biggestbass/sessions">
      Login: <input type="text" placeholder="Enter Username" name="username">
      <input type="password" placeholder="Enter Password" name="password">
      <input type="submit" value="Submit">
    </form>
    </div>
    HTML
  end

  def logout_button(user)
    <<~HTML
    <p align="right">[Logged in as: #{user}]</p>
    <div style="float:right">
    <form align="right" method="get" action="/change_password_ui">
      <button type="submit" formmethod="get" formaction="/biggestbass">Home</button>
      <button type="submit">Change password</button>
      <button type="submit" formmethod="get" formaction="/logout">Logout</button>
    </form>
    </div>
    HTML
  end

  def submit_weight_button(user)
    <<~HTML
    <p align="left">Have an upgrade <b>#{user}</b>? Submit your <b>bullshit</b> catch below!</p>
      <form method="POST" action="/biggestbass/members" enctype="multipart/form-data">
        <b>Step 1:</b> Select fish type<br>
        <input type="radio" name="fish_type" value="largemouth_weight" checked>&nbsp;&nbsp;Largemouth<br>
        <input type="radio" name="fish_type" value="smallmouth_weight">&nbsp;&nbsp;Smallmouth<br><br>
        <b>Step 2:</b> Upload Photos:<br>
        <p>(Both photos are required to submit. JPG files only.)</p>
        <i>Self photo with fish:</i> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="file" name="pic_1" accept="image/jpeg"><br>
        <i>Visible display of weight:</i> <input type="file" name="pic_2" accept="image/jpeg"><br><br>
        <b>Step 3:</b> Enter in your weight:<br>
        <p>
          Acceptable weight input formats:<br>
          <ul>
            <li><i>lbs-oz</i> (eg: 4-12, which equates to 4lbs 12oz)</li>
            <li><i>lbs (decimal)</i> (eg: 3.12, which equates to 3lbs 1oz)</li>
          </ul>
        </p>
        <input type="text" placeholder="lbs-oz / lbs (decimal)" name="upgrade_weight"><br><br>
        <input type="submit" value="Submit Upgrade">
      </form>
    HTML
  end

  def admin_functions_button
    <<~HTML
    <div style="float:right">
    <form align="right" method="get" action="/admin_functions">
      <button type="submit">Admin Functions</button>
    </form>
    </div>
    HTML
  end

  def old_password_incorrect
    <<~HTML
    <p><font color="red">Error: Old password does NOT match</font></p>
    HTML
  end

  def new_passwords_not_match
    <<~HTML
    <p><font color="red">Error: New passwords do NOT match and/or field(s) are empty</font></p>
    HTML
  end

  def new_password_match_old
    <<~HTML
    <p><font color="red">Error: New password matches old password</font></p>
    HTML
  end

  def entry_fee_not_paid
    <<~HTML
    <p><font color="red">Error: Upgrade submission failed. Entry fee has not been paid.</font></p>
    HTML
  end

  def weight_upgrade_submission_failed
    <<~HTML
    <p><b>Reasons may include the following:</b><br>
      <ul>
      <li>Your entry fee has not been paid</li>
      <li>Weight submission field is empty</li>
      <li>Weight submission field contains letter characters</li>
    </ul><br>
    Please review the Global Actions History for more details.
    </p>
    HTML
  end

  def weight_upgrade_field_empty
    <<~HTML
    <p><font color="red">Error: Weight submission field is empty</font></p>
    HTML
  end

  def weight_upgrade_field_white_space
    <<~HTML
    <p><font color="red">Error: Weight submission field must not contain white spaces</font></p>
    HTML
  end

  def weight_upgrade_field_enty_fee_unpaid
    <<~HTML
    <p><font color="red">Error: Entry fee has not been paid</font></p>
    HTML
  end

  def weight_upgrade_field_contains_letters
    <<~HTML
    <p><font color="red">Error: Submission field cannot contain letter characters</font></p>
    HTML
  end

  def weight_upgrade_field_oz_above_16
    <<~HTML
    <p><font color="red">Error: OZ column is higher than 16. (what planet is your scale from?)</font></p>
    HTML
  end

  def weight_upgrade_field_unknown_reason
    <<~HTML
    <p><font color="red">Error: Unable to submit weight (Unknown reason - Please read the instructions below and try again)</font></p>
    HTML
  end

  def weight_upgrade_field_length_exceeds_limit
    <<~HTML
    <p><font color="red">Error: Input length exceeds character limit</font></p>
    HTML
  end

  def weight_upgrade_field_applied_successful
    <<~HTML
    <form><font color="green">Weight upgrade applied successfully! ==> </font>  <button type="submit" formmethod="get" formaction="/biggestbass">Refresh Page</button></form>
    HTML
  end

  def weight_upgrade_field_no_photo
    <<~HTML
    <p><font color="red">Error: Both photo attachments are required with weight upgrade submission</font></p>
    HTML
  end
end
