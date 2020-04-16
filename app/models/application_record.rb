# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.inheritance_column = :inherit_type

  def self.create_from_hash(hash)
    new_hash = {}
    hash.each do |key, value|
      # Once everything is modeled, this should go.
      next unless attribute_method?(key)
      next if value.is_a?(Hash) || value.is_a?(Array)

      new_hash[key.to_sym] = value
    end
    # puts "Creating #{self.name} from #{new_hash}"
    item = create!(new_hash)

    hash.each do |key, value|
      # Once everything is modeled, this should go.
      next unless attribute_method?(key)

      if value.is_a?(Hash)
        # value[join_key(key)] = item.id
        child = clazz_for(key).create_from_hash(value.merge(Hash[join_key(key), item.id]))
        item.public_send("#{key}=", child)
      elsif value.is_a?(Array)
        collection = item.public_send(key)
        collection << value.map do |item_value|
          # item_value[join_key(key)] = item.id
          clazz_for(key).create_from_hash(item_value.merge(Hash[join_key(key), item.id]))
        end
      end
    end
    item.save!

    item
  end

  def update_from_hash(hash)
    new_hash = Hash[filtered_attribute_names.map { |attribute| [attribute.to_sym, nil] }]

    hash.each do |key, value|
      next unless self.class.attribute_method?(key)
      next if value.is_a?(Hash) || value.is_a?(Array)

      new_hash[key.to_sym] = value
    end
    update(new_hash)

    hash.each do |key, value|
      next unless self.class.attribute_method?(key)

      if value.is_a?(Hash)
        child = public_send(key)
        child.update_from_hash(value)
      elsif value.is_a?(Array)
        clazz = self.class.clazz_for(key)
        matching_collection_items = []
        new_collection_items = []
        value.each do |item_value|
          unique_fields = clazz.unique_fields
          collection = public_send(key)
          # Note that some arrays, e.g., release tags, do not have unique fields in which case query is {}
          query = {}.tap { |query| unique_fields.each { |field| query[field] = item_value[field] } }
          collection_item = query.empty? ? nil : collection.find_by(query)
          if collection_item
            collection_item.update_from_hash(item_value)
            matching_collection_items << collection_item
          else
            # item_value[self.class.join_key(key)] = self.id
            new_collection_items << clazz.create_from_hash(item_value.merge(Hash[self.class.join_key(key), id]))
          end
        end
        collection = public_send(key)
        collection.each do |collection_item|
          # byebug if matching_collection_items.include?(collection_item) && key == 'contains'
          collection.destroy(collection_item) unless matching_collection_items.include?(collection_item)
        end
        collection << new_collection_items
      end
    end

    # Remove one-to-ones that are now nil
    self.class.reflect_on_all_associations(:has_one).each do |association|
      next if hash.symbolize_keys.keys.include?(association.name)

      item = public_send(association.name)
      next if item.nil?

      item.destroy!
      public_send("#{association.name}=", nil)
    end

    save!
  end

  def to_cocina_json
    # To json only for attributes
    json = as_json(only: filtered_attribute_names)

    self.class.reflect_on_all_associations(:has_one).each do |association|
      child = public_send(association.name)
      json[association.name.to_s] = child.to_cocina_json unless child.nil?
    end

    self.class.reflect_on_all_associations(:has_many).each do |association|
      child_json = public_send(association.name).map(&:to_cocina_json)
      json[association.name.to_s] = child_json
    end

    # Remove nils
    json.delete_if { |_key, value| value.nil? }

    json
  end

  def all_associations
    self.class.reflect_on_all_associations(:has_one).concat(self.class.reflect_on_all_associations(:has_many))
  end

  def filtered_attribute_names
    attribute_names.filter do |attribute|
      if %w[id created_at updated_at].include?(attribute)
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
    clazz_name = reflect_on_association(key.to_sym).options[:class_name] || key.camelize.singularize
    clazz_name.constantize
  end

  def self.join_key(key)
    reflect_on_association(key.to_sym).join_keys.key
  end
end
