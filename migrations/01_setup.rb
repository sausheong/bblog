Sequel.migration do
  change do
    
    create_table :users do
      primary_key :id
      String :uuid, unique: true
      DateTime :created_at
      String :email, size: 255
      DateTime :date_last_login
      String :password
      String :salt
      String :name
      Boolean :is_admin
    end
    
    create_table :sessions do
      primary_key :id
      String :uuid, unique: true
      DateTime :created_at
      foreign_key :user_id, :users
    end
    
    create_table :posts do
      primary_key :id
      String :uuid, unique: true
      DateTime :created_at
      String :title
      String :content, text: true      
      foreign_key :user_id, :users
    end

    create_table :comments do
      primary_key :id
      String :uuid, unique: true
      DateTime :created_at
      String :content, text: true      
      foreign_key :user_id, :users
      foreign_key :post_id, :posts
    end
  end  
end