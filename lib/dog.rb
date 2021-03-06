require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(h)
      h.each {|k,v| send("#{k}=",v)}
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  end

  def self.create(hash_of_attributes)
      dog = self.new(hash_of_attributes)
      dog.save
      dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      new_dog = self.new_from_db(dog_data)
    else
      new_dog = self.create({:name => name, :breed => breed})
      new_dog.save
    end
    new_dog
  end


  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
      end.first
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id:row[0], name:row[1], breed:row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
  end.first
  end

  def update
    sql = "UPDATE dogs SET name =?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
