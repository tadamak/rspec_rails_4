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
    it "assigns the requested message to @contact"
    it "renders the :show template"
  end

  describe 'GET #new' do
    it "assigns a new Contact to @contact"
    it "renders the :new template"
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
