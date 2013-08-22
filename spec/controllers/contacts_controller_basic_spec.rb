require 'spec_helper'

describe ContactsController do

  describe 'GET #index' do
    # こういうデータがDBにあったとして
    let(:smith) { create(:contact, lastname: 'Smith') }
    let(:jones) { create(:contact, lastname: 'Jones') }

    # こういうパラメータが渡ってきているケースで
    context 'with params[:letter]' do
      # viewで使う@contactsには、こういうデータがセットされているはず
      it "populates an array of contacts starting with the letter" do
        get :index, letter: 'S'
        expect(assigns(:contacts)).to match_array([smith])
      end
      # indexテンプレートがrenderingされるはず
      it "renders the :index view" do
        get :index, letter: 'S'
        expect(response).to render_template :index
      end
    end

    # パラメータ無しの場合
    context 'without params[:letter]' do
      # viewで使う@contactsには、こういうデータがセットされているはず
      it "populates an array of all contacts" do
        get :index
        expect(assigns(:contacts)).to match_array([smith, jones])
      end
      # indexテンプレートがrenderingされるはず
      it "renders the :index view" do
        get :index
        expect(response).to render_template :index
      end
    end
  end

  describe 'GET #show' do
    # こういうデータがDBにあったとして
    let(:contact) { create(:contact, firstname: 'Lawrence', lastname: 'Smith') }
    before do
      # Contactをstub化してあらかじめ仕込んでおいて
      allow(Contact).to receive(:find).with(contact.id.to_s).and_return(contact)
      # こういうリクエストがあったとする
      get :show, id: contact
    end
    # viewで使う@contactには、こういうデータがセットされているはず
    it "assigns the requested message to @contact" do
      expect(assigns(:contact)).to eq contact
    end
    # showテンプレートがrenderingされるはず
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    # こういうリクエストが来ます、と
    before do
      # 簡単なcontrollerのspec例としては邪魔なのでfilterをskip
      controller.class.skip_before_action :authenticate
      get :new
    end
    # @contactには永続化されていないContactオブジェクトがセットされているはず
    it "assigns a new Contact to @contact" do
      expect(assigns(:contact)).to be_a_new(Contact)
    end
    # newテンプレートがrenderingされるはず
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    it "assigns the requested contact to @contact"
    it "renders the :edit template"
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new contact in the database"
      it "redirects to contacts#show"
    end
    context "with invalid attributes" do
      it "does not save the new contact in the database"
      it "re-renders the :new template"
    end
  end

  describe 'PATCH #update' do
    context "with valid attributes" do
      it "updates the contact in the database"
      it "redirects to the contact"
    end

    context "with invalid attributes" do
      it "does not update the contact"
      it "re-renders the #edit template"
    end
  end

  describe 'DELETE #destroy' do
    it "deletes the contact from the database"
    it "redirects to users#index"
  end
end
