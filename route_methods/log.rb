require_relative 'postgres'

class Log
  def initialize
    @pg = PostGres.new
  end

  def get_datetime
    (DateTime.parse(Time.new.to_s)).new_offset('-0600').strftime("%Y-%m-%d %H:%M:%S")
  end

  def log_action(table_name, type, user, action)
    datetime = get_datetime
    @pg.db_insert_data(table_name, 'datetime, type, name, action', "\'#{datetime}\', \'#{type}\', \'#{user}\', \'#{action}\'")
  end

  def delete_log(column, value)
    @pg.delete_table_row('bb_history', column, value)
  end
end
