require_relative 'postgres'

class User
  attr_reader :name

  def initialize(name = nil, password = nil)
    @pg = PostGres.new
    @name = name
    @password = password
  end

  def create_user(role, name, password)
    @pg.db_insert_data('users', 'role, name, password', "\'#{role}\', \'#{name}\', \'#{password}\'")
  end

  def authorized?(name = @name, password = @password)
    user_info = @pg.db_query_user('users', name)
    return false if user_info.nil? || user_info.to_s.empty? || user_info.count.zero?
    return false if user_info['password'] != password
    true
  rescue
    false
  end

  def user_info(name = @name)
    user_info = @pg.db_query_user('users', name)
    return false if user_info.nil? || user_info.to_s.empty? || user_info.count.zero?
    user_info
  end

  def role(name = @name)
    user_info(name)['role']
  end

  def delete_user(name)
    @pg.delete_table_row('users', 'name', name)
  end

  def change_password(new_password, name = @name)
    @pg.update_table_field('users', 'password', new_password, 'name', name)
  end

  def update_role(role, name = @name)
    @pg.update_table_field('users', 'role', role, 'name', name)
  end
end
