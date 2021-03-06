require 'rails_helper'

RSpec.describe Hq::OrphansController, type: :controller do
  let(:orphans) {build_stubbed_list(:orphan, 2)}
  let(:orphan) {build_stubbed :orphan}
  let(:statuses) { [] }
  let(:sponsorship_statuses) { [] }
  let(:provinces) {instance_double Province}

  before :each do
    sign_in instance_double(AdminUser)
  end

  describe '#index' do
    specify "without filters" do
      allow(Orphan).to receive(:filter).and_return Orphan
      expect(Orphan).to receive(:paginate).with(page: "1").and_return orphans
      get :index, page: 1

      expect(assigns(:filters).empty?).to be true
      expect(assigns(:orphans)).to eq orphans
      expect(response).to render_template 'index'
    end

    specify "Filter" do
      filter = build :orphan_filter
      expect(Orphan).to receive_message_chain(:filter,:paginate).with(page: "1").and_return(orphans)
      get :index, {page: 1, filters: filter, commit: "Filter"}

      filter.each_key do |k|
        expect(assigns(:filters)[k].to_s).to eq filter[k].to_s
      end
      expect(assigns(:orphans)).to eq orphans
      expect(response).to render_template 'index'
    end

    specify "Clear Filters" do
      get :index, {page: 1, commit: "Clear Filters"}

      expect(response).to redirect_to hq_orphans_path
    end
  end

  specify '#show' do
    expect(Orphan).to receive(:find).with(orphan.id.to_s).and_return(orphan)
    get :show, id: orphan.id

    expect(assigns(:orphan)).to eq orphan
    expect(response).to render_template 'show'
  end

  context '#edit and #update' do
    before :each do
      expect(Orphan).to receive(:find).with(orphan.id.to_s).and_return(orphan)
    end

    specify 'editing renders the edit view' do
      expect(Orphan).to receive_message_chain(:statuses, :keys, :map).
        and_return(statuses)
      expect(Orphan).to receive_message_chain(:sponsorship_statuses, :keys, :map).
        and_return(sponsorship_statuses)
      expect(Province).to receive(:all).and_return(provinces)
      get :edit, id: orphan.id

      expect(assigns(:orphan)).to eq orphan
      expect(assigns(:statuses)).to eq statuses
      expect(assigns(:sponsorship_statuses)).to eq sponsorship_statuses
      expect(assigns(:provinces)).to eq provinces
      expect(response).to render_template 'edit'
    end

    specify 'successful update redirects to the show view' do
      expect(orphan).to receive(:save).and_return(true)
      patch :update, id: orphan.id, orphan: { name: 'John' }

      expect(response).to redirect_to(hq_orphan_path(orphan))
      expect(flash[:success]).to_not be_nil
    end

    specify 'unsuccessful update renders the edit view' do
      expect(Orphan).to receive_message_chain(:statuses, :keys, :map).
        and_return(statuses)
      expect(Orphan).to receive_message_chain(:sponsorship_statuses, :keys, :map).
        and_return(sponsorship_statuses)
      expect(Province).to receive(:all).and_return(provinces)
      expect(orphan).to receive(:save).and_return(false)
      patch :update, id: orphan.id, orphan: { name: 'John' }

      expect(assigns(:orphan)).to eq orphan
      expect(assigns(:statuses)).to eq statuses
      expect(assigns(:sponsorship_statuses)).to eq sponsorship_statuses
      expect(assigns(:provinces)).to eq provinces
      expect(response).to render_template 'edit'
      expect(flash[:success]).to be_nil
    end
  end
end
