class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.inheritance_column = :inherit_type

  def self.create_from_hash(hash)
    item = self.new_from_hash(hash)
    item.save!
    item
  end

  def self.new_from_hash(hash)
    new_hash = {}
    hash.each do |key, value|
      # Once everything is modeled, this should go.
      next unless self.attribute_method?(key)
      next if value.is_a?(Hash) || value.is_a?(Array)
      puts "Value Key for #{self.name}: #{key}"
      new_hash[key.to_sym] = value
    end
    puts "New hash for #{self.name}: #{new_hash}"
    item = self.new(new_hash)

    hash.each do |key, value|
      # Once everything is modeled, this should go.
      next unless self.attribute_method?(key)
      if value.is_a?(Hash)
        puts "Hash Key for #{self.name}: #{key}"
        child = self.clazz_for(key).new_from_hash(value)
        # byebug
        puts "Setting hash key for #{self.name}: #{key}, #{child}"
        # byebug if key == 'structural' && self.name == 'FileSet'
        item.public_send("#{key}=", child)
        # new_hash[key.to_sym] = self.clazz_for(key).create_from_hash(value)
      elsif value.is_a?(Array)
        puts "Array Key for #{self.name}: #{key}"
        # new_hash[key.to_sym] = value.map { |item_value| self.clazz_for(key).create_from_hash(item_value)}
        collection = item.public_send(key)
        collection << value.map { |item_value| self.clazz_for(key).new_from_hash(item_value)}
      end
    end

    item
  end

  # def self.create_from_hash(hash)
  #   new_hash = {}
  #   hash.each do |key, value|
  #     # Once everything is modeled, this should go.
  #     next unless self.attribute_method?(key)
  #     next if value.is_a?(Hash) || value.is_a?(Array)
  #     puts "Value Key for #{self.name}: #{key}"
  #     new_hash[key.to_sym] = value
  #   end
  #   puts "New hash for #{self.name}: #{new_hash}"
  #   item = self.create(new_hash)
  #
  #   hash.each do |key, value|
  #     # Once everything is modeled, this should go.
  #     next unless self.attribute_method?(key)
  #     if value.is_a?(Hash)
  #       puts "Hash Key for #{self.name}: #{key}"
  #       child = self.clazz_for(key).create_from_hash(value)
  #       byebug
  #       puts "Setting hash key for #{self.name}: #{key}, #{child}"
  #       item.public_send("#{key}=", child)
  #       # new_hash[key.to_sym] = self.clazz_for(key).create_from_hash(value)
  #     elsif value.is_a?(Array)
  #       puts "Array Key for #{self.name}: #{key}"
  #       # new_hash[key.to_sym] = value.map { |item_value| self.clazz_for(key).create_from_hash(item_value)}
  #       collection = item.public_send(key)
  #       collection << value.map { |item_value| self.clazz_for(key).create_from_hash(item_value)}
  #     end
  #   end
  #
  #   item
  # end


  # def self.create_from_hash(hash)
  #   new_hash = {}
  #   hash.each do |key, value|
  #     puts "Key for #{self.name}: #{key}"
  #     next unless self.attribute_method?(key)
  #     if value.is_a?(Hash)
  #       new_hash[key.to_sym] = self.clazz_for(key).create_from_hash(value)
  #     elsif value.is_a?(Array)
  #       new_hash[key.to_sym] = value.map { |item_value| self.clazz_for(key).create_from_hash(item_value)}
  #     else
  #       new_hash[key.to_sym] = value
  #     end
  #   end
  #   puts "New hash for #{self.name}: #{new_hash}"
  #   self.create(new_hash)
  # end


  def update_from_hash(hash)
    puts "Updating #{self.class.name} from hash"
    new_hash = Hash[self.filtered_attribute_names.map { |attribute| [attribute.to_sym, nil] }]
    # self.class.reflect_on_all_associations.each { |association| new_hash[association.name.to_sym] = nil }

    hash.each do |key, value|
      next unless self.class.attribute_method?(key)
      puts "Updating hash key #{key}"
      if value.is_a?(Hash)
        child = self.public_send(key)
        puts "Hash child for #{key}: #{child}, #{child.id}"
        child.update_from_hash(value)
        # new_hash[key.to_sym] = child
        # new_hash.delete(key.to_sym)
      elsif value.is_a?(Array)
        # clazz = key.camelize.singularize.constantize
        clazz = self.class.clazz_for(key)
        matching_collection_items = []
        new_collection_items = []
        value.each do |item_value|
          unique_fields = clazz.unique_fields
          collection = self.public_send(key)
          query = {}.tap {|query| unique_fields.each {|field| query[field] = item_value[field]} }
          collection_item = collection.find_by(query)
          if collection_item
            collection_item.update_from_hash(item_value)
            matching_collection_items << collection_item
            new_collection_items << collection_item
          else
            puts "Creating #{clazz.name} with: #{item_value}"
            new_collection_items << clazz.new_from_hash(item_value)
          end
        end
        collection = self.public_send(key)
        puts "Collection #{key} before destroying: #{collection.count}"
        collection.each do |collection_item|
          unless matching_collection_items.include?(collection_item)
            collection.destroy(collection_item)
            puts "Destroying1 #{collection_item}, #{collection_item.id}"
          end
        end
        puts "Collection after destroying: #{collection.count}"
        collection << new_collection_items
        puts "Collection with new items: #{collection.count}"
        # self.save!
      else
        new_hash[key.to_sym] = value
      end
    end

    puts "Final new_hash for #{self.class.name}: #{new_hash}"
    puts self.destroyed?
    self.update(new_hash)

    self.class.reflect_on_all_associations(:has_one).each do |association|
      unless hash.symbolize_keys.keys.include?(association.name)
        item = self.public_send(association.name)
        item.destroy!
        self.public_send("#{association.name}=", nil)
        puts "Destroying2 #{association.name} #{item}"
      end
    end
  end

  # def update_from_hash(hash)
  #   puts "Updating #{self.class.name} from hash"
  #   new_hash = Hash[self.filtered_attribute_names.map { |attribute| [attribute.to_sym, nil] }]
  #   self.class.reflect_on_all_associations.each { |association| new_hash[association.name.to_sym] = nil }
  #
  #   hash.each do |key, value|
  #     next unless self.class.attribute_method?(key)
  #     if value.is_a?(Hash)
  #       child = self.public_send(key)
  #       puts "Hash child for #{key}: #{child}, #{child.id}"
  #       child.update_from_hash(value)
  #       new_hash[key.to_sym] = child
  #     elsif value.is_a?(Array)
  #       clazz = key.camelize.singularize.constantize
  #       new_hash[key.to_sym] = value.map do |item_value|
  #         unique_fields = clazz.unique_fields
  #         collection = self.public_send(key)
  #         query = {}.tap {|query| unique_fields.each {|field| query[field] = item_value[field]} }
  #         collection_item = collection.find_by(query)
  #         if collection_item
  #           collection_item.update_from_hash(item_value)
  #           collection_item
  #         else
  #           collection_item = clazz.new_from_hash(item_value)
  #           # collection_item.save!
  #           collection_item
  #         end
  #       end
  #     else
  #       new_hash[key.to_sym] = value
  #     end
  #   end
  #
  #   puts "Final new_hash for #{self.class.name}: #{new_hash}"
  #   self.update(new_hash)
  # end


  def to_cocina_json
    # To json only for attributes
    json = self.as_json(only: filtered_attribute_names)

    self.class.reflect_on_all_associations(:has_one).each do |association|
      child = self.public_send(association.name)
      json[association.name.to_s] = child.to_cocina_json unless child.nil?
    end

    self.class.reflect_on_all_associations(:has_many).each do |association|
      child_json = self.public_send(association.name).map {|child| child.to_cocina_json}
      json[association.name.to_s] = child_json
    end

    # Remove nils
    json.delete_if {|_key, value| value.nil? }
    json
  end

  def all_associations
    self.class.reflect_on_all_associations(:has_one).concat(self.class.reflect_on_all_associations(:has_many))
  end

  def filtered_attribute_names
    self.attribute_names.filter do |attribute|
      if ['id', 'created_at', 'updated_at'].include?(attribute)
        false
      elsif association_attribute?(attribute)
        false
      else
        true
      end
    end
  end

  def association_attribute?(name)
    self.class.reflect_on_all_associations(:belongs_to).each do |association|
      return true if association.foreign_key == name
    end
    false
  end

  def self.clazz_for(key)
    clazz_name = self.reflect_on_association(key.to_sym).options[:class_name] || key.camelize.singularize
    clazz_name.constantize
  end
end
