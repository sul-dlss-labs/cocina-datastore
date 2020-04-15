# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.inheritance_column = :inherit_type

  def self.create_from_hash(hash)
    item = new_from_hash(hash)
    item.save!
    item
  end

  def self.new_from_hash(hash)
    new_hash = {}
    hash.each do |key, value|
      # Once everything is modeled, this should go.
      next unless attribute_method?(key)
      next if value.is_a?(Hash) || value.is_a?(Array)

      new_hash[key.to_sym] = value
    end
    item = new(new_hash)

    hash.each do |key, value|
      # Once everything is modeled, this should go.
      next unless attribute_method?(key)

      if value.is_a?(Hash)
        child = clazz_for(key).new_from_hash(value)
        item.public_send("#{key}=", child)
      elsif value.is_a?(Array)
        collection = item.public_send(key)
        collection << value.map { |item_value| clazz_for(key).new_from_hash(item_value) }
      end
    end

    item
  end

  def update_from_hash(hash)
    new_hash = Hash[filtered_attribute_names.map { |attribute| [attribute.to_sym, nil] }]

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
            new_collection_items << collection_item
          else
            new_collection_items << clazz.new_from_hash(item_value)
          end
        end
        collection = public_send(key)
        collection.each do |collection_item|
          collection.destroy(collection_item) unless matching_collection_items.include?(collection_item)
        end
        collection << new_collection_items
      else
        new_hash[key.to_sym] = value
      end
    end

    update(new_hash)

    self.class.reflect_on_all_associations(:has_one).each do |association|
      next if hash.symbolize_keys.keys.include?(association.name)

      item = public_send(association.name)
      next if item.nil?

      item.destroy!
      public_send("#{association.name}=", nil)
    end
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
end
