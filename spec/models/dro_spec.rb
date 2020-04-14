require 'rails_helper'

RSpec.describe Dro, type: :model do
  let(:json) do
    JSON.parse(File.read('spec/fixtures/druid:bb522hg1591.json'))
  end

  let(:dro) { described_class.create_from_hash(json)}

  describe '#create_from_hash' do
    it 'is populated' do
      # DRO
      expect(dro.type).to eq('http://cocina.sul.stanford.edu/models/book.jsonld')
      expect(dro.externalIdentifier).to eq('druid:bb522hg1591')
      expect(dro.label).to eq('Border violence')
      expect(dro.version).to eq(1)

      # DRO > Access
      expect(dro.access.access).to eq('citation-only')

      # DRO > Structural > hasMemberOrders
      expect(dro.structural.hasMemberOrders.size).to eq(1)
      expect(dro.structural.hasMemberOrders.first.viewingDirection).to eq('left-to-right')

      # DRO > Structural > contains
      expect(dro.structural.contains.size).to eq(2)
      file_set = dro.structural.contains.first
      expect(file_set.type).to eq('http://cocina.sul.stanford.edu/models/fileset.jsonld')
      expect(file_set.externalIdentifier).to eq('bb522hg1591_1')
      expect(file_set.label).to eq('Page 1')
      expect(file_set.version).to eq(1)
    end
  end

  describe '#update_from_hash' do
    before do
      dro.update_from_hash(updated_hash)
    end

    context 'when change values' do
      let(:updated_hash) do
        hash = json.dup
        hash['type'] = "http://cocina.sul.stanford.edu/models/object.jsonld"
        hash['externalIdentifier'] = "druid:bb522hg1592"
        hash['label'] = "Border violencex"
        hash['version'] = 2
        hash['access']['access'] = 'world'
        hash['structural']['hasMemberOrders'][0]['viewingDirection'] = 'right-to-left'
        hash
      end

      it 'is updated' do
        expect(dro.type).to eq('http://cocina.sul.stanford.edu/models/object.jsonld')
        expect(dro.externalIdentifier).to eq('druid:bb522hg1592')
        expect(dro.label).to eq('Border violencex')
        expect(dro.version).to eq(2)
        expect(dro.access.access).to eq('world')
        expect(dro.structural.hasMemberOrders.size).to eq(1)
        expect(dro.structural.hasMemberOrders.first.viewingDirection).to eq('right-to-left')
      end
    end

    context 'when remove optional values' do
      let(:updated_hash) do
        {
            type: "http://cocina.sul.stanford.edu/models/object.jsonld",
            externalIdentifier: "druid:bb522hg1592",
            label: "Border violencex",
            version: 2,
            access: {}
        }
      end

      it 'sets value to nil' do
        expect(dro.access.access).to be_nil
      end


    end

    context 'when remove optional associated models' do
      let(:updated_hash) do
        {
            type: "http://cocina.sul.stanford.edu/models/object.jsonld",
            externalIdentifier: "druid:bb522hg1592",
            label: "Border violencex",
            version: 2
        }
      end

      it 'sets value to nil' do
        expect(dro.access).to be_nil
        expect(Access.count).to eq(0)
      end
    end

    context 'when change arrays' do
      let(:updated_hash) do
        hash = json.dup
        # Change fileset
        hash['structural']['contains'][0]['version'] = 2
        # Remove fileset
        hash['structural']['contains'].delete_at(1)
        # Add fileset
        hash['structural']['contains'] << {
            type: 'http://cocina.sul.stanford.edu/models/fileset.jsonld',
            externalIdentifier: "bb522hg1591_3",
            label: "Page 3",
            version: 1
        }
        hash
      end

      it 'updates array' do
        expect(dro.structural.contains.size).to eq(2)
        expect(dro.structural.contains[0].version).to eq(2)
        expect(dro.structural.contains[1].externalIdentifier).to eq('bb522hg1591_3')
      end
    end

  end

  describe '#to_cocina_model' do
    let(:cocina_dro) { dro.to_cocina_model }

    let(:expected) {
      {
        type: "http://cocina.sul.stanford.edu/models/book.jsonld",
        externalIdentifier: "druid:bb522hg1591",
        label: "Border violence",
        version: 1,
        access: {
          access: "citation-only"
        },
        structural: {
          hasMemberOrders: [
            { viewingDirection: 'left-to-right' }
          ],
          contains: [
              {
                externalIdentifier: "bb522hg1591_1",
                label: "Page 1",
                type: "http://cocina.sul.stanford.edu/models/fileset.jsonld",
                version: 1
              },
              {
                  externalIdentifier: "bb522hg1591_2",
                  label: "Page 2",
                  type: "http://cocina.sul.stanford.edu/models/fileset.jsonld",
                  version: 1
              }
          ]
        }
      }

    }

    it 'returns a cocina model' do
      expect(cocina_dro).to be_a(Cocina::Models::DRO)
      expect(cocina_dro.to_h).to eq(expected)
    end
  end
end