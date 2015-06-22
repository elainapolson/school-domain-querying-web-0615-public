require 'pry'

class Course
  attr_accessor :id, :name, :department, :department_id, :departments, :students

  def initialize
    @students = []
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS courses 
      ( id INTEGER PRIMARY KEY,
        name TEXT,
        department_id INTEGER
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL    
      DROP TABLE IF EXISTS courses;
    SQL

    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL
      INSERT INTO courses (name, department_id) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, name, department_id)    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM courses")[0][0]
  end

  def update
    sql = <<-SQL
      UPDATE courses SET name = ?, department_id = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, department_id, id) 
  end


  def persisted?
    !!self.id
  end

  def save
    persisted? ? update : insert
  end

  def self.new_from_db(row)
    self.new.tap do |c|
      c.id = row[0]
      c.name =  row[1]
      c.department_id = row[2]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM courses WHERE name = ? 
    SQL

    DB[:conn].execute(sql, name).collect do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_all_by_department_id(department_id)
    sql = <<-SQL
      SELECT * FROM courses WHERE department_id = ?
    SQL
    DB[:conn].execute(sql, department_id).collect do |row|  
      self.new_from_db(row)
    end
  end

  def department=(department)
    department.courses << self
    self.department_id = department.id 
  end

  def department
    Department.find_by_id(department_id)
  end 

  def add_student(student)
    self.students << student
  end


end
