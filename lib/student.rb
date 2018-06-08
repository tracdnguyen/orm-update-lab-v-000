require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
    id INTEGER PRIMARY KEY,
    name TEXT,
    grade INTEGER);
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
       self.update
     else
       sql = <<-SQL
         INSERT INTO students (name, grade)
         VALUES (?, ?)
       SQL
       DB[:conn].execute(sql, self.name, self.grade)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
     end
   end

   def self.create(name, grade)
     student = self.new(name, grade)
     student.save
     student
   end

   def self.new_from_db(student)
     student = self.new(student[0], student[1], student[2])
     student
    end

   def update
     sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.grade, self.id)
   end

   def self.find_by_name(name)
     sql = "SELECT * FROM students WHERE name = ? LIMIT 1;"
     DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
     end.first
   end

end
