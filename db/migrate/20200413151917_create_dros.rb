class CreateDros < ActiveRecord::Migration[6.0]
  def change

    # TODO: description
    create_table :dros do |t|
      t.string :type, null: false
      t.string :externalIdentifier, null: false
      t.string :label, null: false
      t.integer :version, null: false
      t.timestamps
      t.index :externalIdentifier, unique: true
    end

    create_table :droAccesses do |t|
      t.belongs_to :dro, index: { unique: true }, foreign_key: true
      t.string :access
      t.string :copyright
      t.string :download
      t.string :readLocation
      t.string :useAndReproductionStatement
      t.timestamps
    end

    create_table :embargoes do |t|
      t.belongs_to :droAccess, index: { unique: true }, foreign_key: true
      t.datetime :releaseDate, null: false
      t.string :access, null: false
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

    create_table :fileSetStructurals do |t|
      t.belongs_to :fileSet, index: { unique: true }, foreign_key: true
      t.timestamps
    end

    # File doesn't work well as a class name so using droFile.
    create_table :droFiles do |t|
      t.belongs_to :fileSetStructural, foreign_key: true
      t.string :type, null: false
      t.string :externalIdentifier, null: false
      t.string :label, null: false
      t.string :filename
      t.integer :size, limit: 8
      t.integer :version, null: false
      t.string :hasMimeType
      t.string :use
      t.timestamps
      t.index [:fileSetStructural_id, :externalIdentifier], unique: true
    end

    create_table :messageDigests do |t|
      t.belongs_to :droFile, foreign_key: true
      t.string :type, null: false
      t.string :digest, null: false
      t.timestamps
      t.index [:droFile_id, :type], unique: true
    end

    create_table :accesses do |t|
      t.belongs_to :droFile, index: { unique: true }, foreign_key: true
      t.string :access
      t.string :download
      t.string :readLocation
      t.timestamps
    end

    create_table :fileAdministratives do |t|
      t.belongs_to :droFile, index: { unique: true }, foreign_key: true
      t.boolean :sdrPreserve, null: false
      t.boolean :shelve, null: false
      t.timestamps
    end

    create_table :presentations do |t|
      t.belongs_to :droFile, index: { unique: true }, foreign_key: true
      t.integer :height
      t.integer :width
      t.timestamps
    end

    create_table :administratives do |t|
      t.belongs_to :dro, index: { unique: true }, foreign_key: true
      t.string :hasAdminPolicy
      t.string :partOfProject
      t.timestamps
    end

    create_table :releaseTags do |t|
      t.belongs_to :administrative, foreign_key: true
      t.string :who
      t.string :what
      t.datetime :date
      t.string :to
      t.boolean :release, null: false
      t.timestamps
    end

    create_table :identifications do |t|
      t.belongs_to :dro, index: { unique: true }, foreign_key: true
      t.string :sourceId
      t.timestamps
    end

    create_table :catalogLinks do |t|
      t.belongs_to :identification, foreign_key: true
      t.string :catalog, null: false
      t.string :catalogRecordId, null: false
      t.timestamps
      t.index [:identification_id, :catalog], unique: true
    end

    create_table :geographics do |t|
      t.belongs_to :dro, index: { unique: true }, foreign_key: true
      t.string :iso19139
      t.timestamps
    end

  end
end
