class CreateDros < ActiveRecord::Migration[6.0]
  def change
    # TODO: Put unique index on externalIdentifier
    create_table :dros do |t|
      t.string :type, null: false
      t.string :externalIdentifier, null: false
      t.string :label, null: false
      t.integer :version, null: false
      t.timestamps
      t.index :externalIdentifier, unique: true
    end

    create_table :accesses do |t|
      t.belongs_to :dro, index: { unique: true }, foreign_key: true
      t.string :access
      t.string :copyright
      t.string :download
      t.string :readLocation
      t.string :useAndReproductionStatement
      t.timestamps
    end

    create_table :droStructurals do |t|
      t.belongs_to :dro, index: { unique: true }, foreign_key: true
      t.string :isMemberOf # Not modeling this as an association.
      t.string :hasAgreement
      t.timestamps
    end

    create_table :sequences do |t|
      t.belongs_to :droStructural, foreign_key: true
      t.string :viewingDirection
      t.timestamps
      t.index [:droStructural_id, :viewingDirection], unique: true
    end

    create_table :fileSets do |t|
      t.belongs_to :droStructural, foreign_key: true
      t.string :type, null: false
      t.string :externalIdentifier, null: false
      t.string :label, null: false
      t.integer :version, null: false
      t.timestamps
      t.index [:droStructural_id, :externalIdentifier], unique: true
    end
  end
end
