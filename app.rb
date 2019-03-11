require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/namespace'
require_relative 'route_methods/postgres'
require_relative 'route_methods/biggestbass'
require_relative 'route_methods/user'
require_relative 'route_methods/html'
require_relative 'route_methods/log'

# set port and binding
set :bind, '0.0.0.0'
set :port, 8080
set :sessions, :expire_after => 1800

# presets - load classes
before do
  @html = HTML.new
  @bb = BiggestBass.new
  @log = Log.new
  @pg = PostGres.new
end

# Endpoints

# General end points

get '/unauthorized' do
  @message = 'Invalid username / password'
  erb :unauthorized
end

get '/logout' do
  @bb.bblog('info', session[:userid], 'Logged out successfully') unless session[:userid].nil?
  session[:userid] = nil
  redirect '/biggestbass'
end

# Admin functions

get '/admin_functions' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  @user_session_status = @html.logout_button(session[:userid])
  @admin_functions_button = @html.admin_functions_button if session[:role] == 'admin'
  erb :admin_functions
end

post '/add_new_user' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  User.new.create_user(params['role'], params['username'], params['password'])
  redirect back
end

post '/delete_user' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  User.new.delete_user(params['username'])
  redirect back
end

post '/reset_user_password' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  User.new.change_password(params['new_password'], params['username'])
  redirect back
end

post '/clear_table' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  @pg.clear_table(params['table_name'])
  redirect back
end

# Change password

get '/change_password_ui' do
  redirect '/unauthorized' if session[:userid].nil?
  @user_session_status = @html.logout_button(session[:userid])
  @bb.bblog('info', session[:userid], 'Is attempting to change his/her password')
  erb :change_password_ui
end

post '/change_password' do
  redirect '/unauthorized' if session[:userid].nil?
  @user = User.new(session[:userid], params['old_password'])
  if !params['old_password'].match(/\w/) || !@user.authorized?
    @error_msg = @html.old_password_incorrect
    @bb.bblog('warning', session[:userid], "Tried changing password but received: Error => Old password does NOT match")
    erb :change_password_ui
  elsif !params['new_password'].match(/\w/) || !params['new_password2'].match(/\w/) || params['new_password'] != params['new_password2']
    @error_msg = @html.new_passwords_not_match
    @bb.bblog('warning', session[:userid], "Tried changing password but received: Error => New passwords do NOT match and/or field(s) are empty")
    erb :change_password_ui
  elsif params['new_password'] == params['old_password']
    @error_msg = @html.new_password_match_old
    @bb.bblog('warning', session[:userid], "Tried changing password but received: Error => New password matches old password")
    erb :change_password_ui
  else
    @user.change_password(params['new_password'])
    @bb.bblog('info', session[:userid], 'Changed password successfully')
    @bb.bblog('info', session[:userid], 'automatically logged out after changing password')
    session[:userid] = nil
    erb :password_change_successful
  end
end

# Biggest bass stuff ======================================================

get '/biggestbass' do
  redirect '/biggestbass/members' if session[:userid] && session[:site] == 'biggestbass'
  @user_session_status = @html.login_button if session[:userid].nil?
  @title = "Biggest Bass Leaderboard"
  @bb_table = @bb.sort_by_weight
  erb :biggestbass
end

get '/biggestbass/members' do
  redirect '/biggestbass' if session[:userid].nil? && session[:site] != 'biggestbass'
  @user_session_status = @html.logout_button(session[:userid])
  @submit_weight = @html.submit_weight_button(session[:userid])
  @admin_functions_button = @html.admin_functions_button if session[:role] == 'admin'
  @title = "Biggest Bass Leaderboard"
  @bb_table = @bb.sort_by_weight || []
  @bb_history = @bb.history_table || []
  erb :biggestbass_members
end

post '/biggestbass/sessions' do
  @user = User.new(params['username'], params['password'])
  if @user.authorized?
    session[:userid] = @user.name
    session[:role] = @user.role
    session[:site] = 'biggestbass'
    @bb.bblog('info', session[:userid], 'Logged in successfully')
    redirect '/biggestbass/members'
  else
    @bb.bblog('warning', params['username'], 'Login failed')
    redirect '/unauthorized'
  end
end

post '/biggestbass/members' do
  redirect '/unauthorized' if session[:userid].nil? && session[:site] != 'biggestbass'
  if params[:pic_1] && params[:pic_2]
    #extension = params[:pic_1][:filename].split(//).last(3).join("").to_s
    filename = "#{session[:userid]}_#{params['fish_type']}_1.jpg"
    tempfile = params[:pic_1][:tempfile]
    target = "public/uploads/#{filename}"
    File.open(target, 'wb') {|f| f.write tempfile.read }

    #extension = params[:pic_2][:filename].split(//).last(3).join("").to_s
    filename = "#{session[:userid]}_#{params['fish_type']}_2.jpg"
    tempfile = params[:pic_2][:tempfile]
    target = "public/uploads/#{filename}"
    File.open(target, 'wb') {|f| f.write tempfile.read }
  else
    @bb.bblog('warning', session[:userid], "Attempted to submit a weight upgrade but no photo was attached with submission")
    @error_msg = @html.weight_upgrade_field_no_photo
  end

  if params[:pic_1].nil? || params[:pic_1].to_s.empty? || params[:pic_2].nil? || params[:pic_2].to_s.empty?
  elsif params['upgrade_weight'].to_s.empty?
    @bb.bblog('warning', session[:userid], 'Attempted to submit an upgrade with an empty field.')
    @error_msg = @html.weight_upgrade_field_empty
  elsif params['upgrade_weight'].match(/\s/)
    @bb.bblog('warning', session[:userid], 'Attempted to submit an upgrade with white space(s) in the field')
    @error_msg = @html.weight_upgrade_field_white_space
  elsif params['upgrade_weight'].match(/[A-Za-z]/)
    @bb.bblog('warning', session[:userid], 'Attempted to submit an upgrade with letter characters in the field')
    @error_msg = @html.weight_upgrade_field_contains_letters
  elsif !@bb.entry_fee_paid?(session[:userid], '$120')
    @bb.bblog('warning', session[:userid], 'Attempted to submit a weight upgrade but failed due to entry fee not paid')
    @error_msg = @html.weight_upgrade_field_enty_fee_unpaid
  elsif params['upgrade_weight'].to_s.match(/\d{1,2}\-\d{1,2}/)
    upgrade_weight = params['upgrade_weight']
    if upgrade_weight.to_s.match(/\d{1,2}\-\d{1,2}/)[0].length != upgrade_weight.length
      @bb.bblog('warning', session[:userid], "Attempted to submit a weight upgrade but input length exceeds character limit. User submitted: \"#{upgrade_weight}\"")
      @error_msg = @html.weight_upgrade_field_length_exceeds_limit
    elsif upgrade_weight.split('-')[1].to_i > 16
      @bb.bblog('warning', session[:userid], 'Attempted to submit a weight upgrade with oz higher than 16')
      @error_msg = @html.weight_upgrade_field_oz_above_16
    else
      @bb.bblog('info', session[:userid], "Submitted an upgrade for #{params['fish_type']} @ #{params['upgrade_weight']}")
    end
  elsif params['upgrade_weight'].to_s.match(/\d{1,2}\.\d{1,3}/)
    if params['upgrade_weight'].to_s.match(/\d{1,2}\.\d{1,3}/)[0].length != params['upgrade_weight'].length
      @bb.bblog('warning', session[:userid], "Attempted to submit a weight upgrade but input length exceeds character limit. User submitted: \"#{params['upgrade_weight']}\"")
      @error_msg = @html.weight_upgrade_field_length_exceeds_limit
    else
      upgrade_weight = @bb.convert_decimal_to_lbs_oz(params['upgrade_weight'])
      @bb.bblog('info', session[:userid], "Submitted an upgrade for #{params['fish_type']} @ #{upgrade_weight}")
    end
  else
    @bb.bblog('warning', session[:userid], "Invalid weight input format (unknown reason). User submitted: \"#{params['upgrade_weight']}\"")
    @error_msg = @html.weight_upgrade_field_unknown_reason
  end

  @success_msg = @html.weight_upgrade_field_applied_successful unless !@error_msg.nil? || !@error_msg.to_s.empty?
  @bb.update_bass_weight(@log.get_datetime, session[:userid], params['fish_type'], upgrade_weight) unless !@error_msg.nil? || !@error_msg.to_s.empty?
  @user_session_status = @html.logout_button(session[:userid])
  @admin_functions_button = @html.admin_functions_button if session[:role] == 'admin'
  @submit_weight = @html.submit_weight_button(session[:userid])
  @title = "Biggest Bass Leaderboard"
  @bb_table = @bb.sort_by_weight || []
  @bb_history = @bb.history_table || []
  erb :biggestbass_members
end

post '/clear_action_logs' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  @user_session_status = @html.logout_button(session[:userid])
  @admin_functions_button = @html.admin_functions_button if session[:role] == 'admin'
  @pg.clear_table('bb_history')
  redirect back
end

post '/add_bb_entry_fee' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  @bb.paid_entry_fee(@log.get_datetime, params['username'], params['entry_fee_paid'])
  @bb.bblog('info', session[:userid], "#{params['username']} paid entry fee, weight submission set to enabled")
  redirect back
end

post '/add_bb_user' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  @bb.add_bb_user(params['username'])
  @bb.bblog('info', session[:userid], "User #{params['username']} has been added")
  redirect back
end

post '/remove_bb_user' do
  redirect '/unauthorized' if session[:userid].nil? || session[:role] != 'admin'
  @bb.remove_bb_user(params['username'])
  @bb.bblog('info', session[:userid], "User #{params['username']} has been removed")
  redirect back
end

# B545 ======================================================

get '/b545' do
  # create DB!!!
  # create_table('b545', 'rank TEXT UNIQUE, name varchar(32) PRIMARY KEY UNIQUE, date_caught TEXT, fish_1 TEXT, fish_2 TEXT, fish_3 TEXT, fish_4 TEXT, fish_5 TEXT, total_weight TEXT')
  @number = 2
  erb :b545_members
end

get '/b545/members' do

end

post '/b545/members' do

end

post '/b545/sessions' do
  @user = User.new(params['username'], params['password'])
  if @user.authorized?
    session[:userid] = @user.name
    session[:role] = @user.role
    session[:site] = 'b545'
    @bb.bblog('info', session[:userid], 'Logged in successfully')
    redirect '/biggestbass/members'
  else
    @bb.bblog('warning', params['username'], 'Login failed')
    redirect '/unauthorized'
  end
end
