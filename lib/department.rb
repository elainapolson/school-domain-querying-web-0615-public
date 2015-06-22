class Department
	
  attr_accessor :id, :name, :courses

  @@all = []

  def initialize
    @courses = []
    @@all << self
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS departments (
      id INTEGER PRIMARY KEY,
      name TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL 
      DROP TABLE IF EXISTS departments 
    SQL
    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL 
      INSERT INTO departments (name) VALUES (?)
    SQL
    DB[:conn].execute(sql, name)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM departments")[0][0]
  end

  def update
    sql = <<-SQL 
      UPDATE departments SET name = ?
    SQL
    DB[:conn].execute(sql, name)    
  end

  def persisted?
    !!self.id
  end

  def save
    if persisted? 
      update 
    else
      insert
    end
  end

  def self.new_from_db(row)
    self.new.tap do |dept|
      dept.id = row[0]
      dept.name = row[1]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM departments WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).collect do |row|
      self.new_from_db(row)
      end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM departments WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).collect do |row|
      self.new_from_db(row)
      end.first
  end

  def courses
    Course.find_all_by_department_id(self.id)
  end

  def add_course(course)
    course.department_id = self.id
    course.update
    save
  end



end
