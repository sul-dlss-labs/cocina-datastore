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

      # DRO > Access > embargo
      expect(dro.access.embargo.access).to eq('world')
      puts dro.access.embargo.releaseDate

      # DRO > Structural > hasMemberOrders
      expect(dro.structural.hasMemberOrders.size).to eq(1)
      expect(dro.structural.hasMemberOrders.first.viewingDirection).to eq('left-to-right')

      # DRO > Structural > contains
      expect(dro.structural.contains.size).to eq(2)

      # DRO > Structural > contains > FileSet
      file_set = dro.structural.contains.first
      expect(file_set.type).to eq('http://cocina.sul.stanford.edu/models/fileset.jsonld')
      expect(file_set.externalIdentifier).to eq('bb522hg1591_1')
      expect(file_set.label).to eq('Page 1')
      expect(file_set.version).to eq(1)

      # DRO > Structural > contains > FileSet > Structural > contains
      expect(file_set.structural.contains.size).to eq(3)

      # DRO > Structural > contains > FileSet > Structural > contains > File
      file = file_set.structural.contains.first
      expect(file.type).to eq('http://cocina.sul.stanford.edu/models/file.jsonld')
      expect(file.externalIdentifier).to eq('druid:bb522hg1591/00000001.html')
      expect(file.label).to eq('00000001.html')
      expect(file.size).to eq(966)
      expect(file.version).to eq(1)
      expect(file.hasMimeType).to eq('text/html')

      # DRO > Structural > contains > FileSet > Structural > contains > File > hasMessageDigests
      expect(file.hasMessageDigests.size).to eq(2)

      # DRO > Structural > contains > FileSet > Structural > contains > File > hasMessageDigests > MessageDigest
      message_digest = file.hasMessageDigests.first
      expect(message_digest.type).to eq('sha1')
      expect(message_digest.digest).to eq('c4980d27f9358338ce60643525656e6c3d7c231c')

      # DRO > Structural > contains > FileSet > Structural > contains > File > access
      expect(file.access.access).to eq('dark')

      # DRO > Structural > contains > FileSet > Structural > contains > File > administrative
      expect(file.administrative.sdrPreserve).to be true
      expect(file.administrative.shelve).to be false

      # DRO > Structural > contains > FileSet > Structural > contains > File > presentation
      image_file = file_set.structural.contains[1]
      expect(image_file.presentation.height).to eq(250)
      expect(image_file.presentation.width).to eq(350)


        # "type": "http://cocina.sul.stanford.edu/models/file.jsonld",
      #     "externalIdentifier": "druid:bb522hg1591/00000001.html",
      #     "label": "00000001.html",
      #     "filename": "00000001.html",
      #     "size": 966,
      #     "version": 1,
      #     "hasMimeType": "text/html",
      #     "hasMessageDigests": [
      #     {
      #         "type": "sha1",
      #         "digest": "c4980d27f9358338ce60643525656e6c3d7c231c"
      #     },
      #     {
      #         "type": "md5",
      #         "digest": "1a8ffd0c470f80f0dab7137f995176b9"
      #     }
      # ],
      #     "access": {
      #     "access": "dark"
      # },
      #     "administrative": {
      #     "sdrPreserve": true,
      #     "shelve": false
      # }
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