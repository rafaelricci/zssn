require 'rails_helper'

RSpec.describe Survivors::TradeService, type: :service do
  describe '#call' do
    let(:offerer) { create(:survivor) }
    let(:receiver) { create(:survivor) }

    before do
      offerer.inventories.each { |i| i.update(quantity: 5) }
      receiver.inventories.each { |i| i.update(quantity: 5) }
    end

    let(:offer_items) { { water: 1, food: 1 } }
    let(:request_items) { { medicine: 1, ammo: 2 } }

    context 'when trade is valid' do
      let(:request_items) { { medicine: 1, ammo: 1 } }
      let(:offer_items) { { food: 1 } }
      let(:result) do
        described_class.call(
          offerer_id: offerer.id,
          receiver_id: receiver.id,
          offer_items: offer_items,
          request_items: request_items
        )
      end

      it 'returns success result' do
        expect(result).to be_success
      end

      it 'includes confirmation message' do
        expect(result.data).to eq("Trade completed successfully")
      end
    end

    context 'when offerer and receiver are the same survivor' do
      let(:result) do
        described_class.call(
          offerer_id: offerer.id,
          receiver_id: offerer.id,
          offer_items: offer_items,
          request_items: request_items
        )
      end

      it 'returns failure result' do
        expect(result).to be_failure
      end

      it 'includes error message about self-trading' do
        expect(result.error).to eq("Cannot trade with yourself")
      end
    end

    context 'when one of the survivors is infected' do
      before do
        create_list(:infection_report, 3, reported: offerer)
      end

      let(:result) do
        described_class.call(
          offerer_id: offerer.id,
          receiver_id: receiver.id,
          offer_items: offer_items,
          request_items: request_items
        )
      end

      it 'returns failure result' do
        expect(result).to be_failure
      end

      it 'includes error message about infection' do
        expect(result.error).to eq("One or both survivors are infected")
      end
    end

    context 'when trade is unfair' do
      let(:result) do
        described_class.call(
          offerer_id: offerer.id,
          receiver_id: receiver.id,
          offer_items: offer_items,
          request_items: request_items
        )
      end

      it 'returns failure result' do
        expect(result).to be_failure
      end

      it 'includes error message about fairness' do
        expect(result.error).to eq("Unfair trade. Point values must match")
      end
    end
  end
end
