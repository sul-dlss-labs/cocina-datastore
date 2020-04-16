# frozen_string_literal: true

namespace :cd do
  desc 'Generate a random DRO'
  task generate: :environment do
    puts JSON.pretty_generate(RandomDroGenerator.generate.to_h)
  end

  desc 'Create a random DRO'
  task :create, [:count] => :environment do |_task, args|
    Parallel.each((1..args[:count].to_i).to_a, in_processes: Etc.nprocessors - 1, progress: 'Creating') do
      cocina_dro = RandomDroGenerator.generate
      dro = Dro.create_from_hash(JSON.parse(cocina_dro.to_json))
      puts "Created #{dro.externalIdentifier} (Worker: #{Parallel.worker_number})"
    end
    puts "Total DROs in db: #{Dro.count}"
  end

  desc 'JSON for a DRO'
  task :json, [:druid] => :environment do |_task, args|
    dro = Dro.find_by(externalIdentifier: args[:druid])
    puts JSON.pretty_generate(dro.to_cocina_model.to_h)
  end
end
