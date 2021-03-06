require 'pry'

class Dog 


attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name 
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
        SQL
    
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
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
        end
        self
    end

    def self.create(attr_hash)
        dog = Dog.new(attr_hash)
        attr_hash.each {|key, value| dog.send(("#{key}="), value)}
        dog.save
    end

    def self.new_from_db(row)
        self.new(name: row[1], breed: row[2], id: row[0])
    end 
    
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Dog.new(name: result[1], breed: result[2], id: result[0])
    end

    def self.find_or_create_by(attr_hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_hash[:name], attr_hash[:breed])
        if !dog.empty?
            blank = dog[0]
            dog = self.new_from_db(blank)
        else 
            dog = self.create(attr_hash)
        end 
        dog 
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        Dog.new(name: result[1], breed: result[2], id: result[0])
    end 
    
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
