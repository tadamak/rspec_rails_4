require 'spec_helper'

describe ContactsController do
  let(:phones) {
    [
      attributes_for(:phone, phone_type: "home"),
      attributes_for(:phone, phone_type: "office"),
      attributes_for(:phone, phone_type: "mobile")
    ]
  }

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
    let(:contact) { create(:contact, firstname: 'Lawrence', lastname: 'Smith') }
    before do
      controller.class.skip_before_action :authenticate
      get :edit, id: contact
    end
    # viewで使う@contactには、パラメータで渡したidをもつContactオブジェクトがセットされていること
    it "assigns the requested contact to @contact" do
      expect(assigns(:contact)).to eq contact
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    before do
      controller.class.skip_before_action :authenticate
    end

    # ちゃんとしたパラメータだったらどうなるか
    context "with valid attributes" do
      before do
        post :create, contact: attributes_for(:contact, phones_attributes: phones)
      end
      # 新規に保存されていることを確認
      it "saves the new contact in the database" do
        expect(Contact.exists? assigns[:contact]).to be_true
        # 以下のようにContactクラスのobject数が1増えていることを確認するのも有り
        # expect {
        #   post :create, contact: attributes_for(:contact, phones_attributes: phones)
        # }.to change(Contact, :count).by(1)
      end
      # showへリダイレクトされるはず
      it "redirects to contacts#show" do
        expect(response).to redirect_to Contact.last
      end
    end

    # 不正なパラメータならどうなるか
    context "with invalid attributes" do
      # 保存されないはず
      it "does not save the new contact in the database" do
        expect {
          post :create, contact: attributes_for(:contact)
        }.to_not change(Contact, :count)
      end
      # 検証失敗でnewがレンダリングされるはず
      it "re-renders the :new template" do
        post :create, contact: attributes_for(:contact)
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    # 元々こういうデータが永続化されていたとする
    let(:contact) { create(:contact, firstname: 'Lawrence', lastname: 'Smith') }

    before do
      controller.class.skip_before_action :authenticate
    end

    # validなパラメータが渡った場合
    context "with valid attributes" do
      # 指定したidのobjectがセットされていること
      it "located the requested @contact" do
        patch :update, id: contact, contact: attributes_for(:contact)
        expect(assigns(:contact)).to eq contact
      end
      # ちゃんと渡したパラメータで更新されていること
      it "changes contact's attributes" do
        patch :update, id: contact,
              contact: attributes_for(:contact, firstname: 'Larry', lastname: 'Wall')
        contact.reload
        expect(contact.firstname).to eq 'Larry'
        expect(contact.lastname).to eq('Wall')
      end
      # 更新されたらリダイレクトされていること
      it "redirects to the contact" do
        patch :update, id: contact, contact: attributes_for(:contact)
        expect(response).to redirect_to contact
      end
    end

    # invalidなパラメータの場合
    context "with invalid attributes" do
      # invalidなパラメータ用意
      let(:invalid_attr) do
        attributes_for(:contact, firstname: 'Larry', lastname: nil)
      end

      before do
        allow(contact).to receive(:update).with(invalid_attr.stringify_keys) { false }
        patch :update, id: contact, contact: invalid_attr
      end

      # 指定したidのobjectがセットされていること
      it "located the requested @contact" do
        expect(assigns(:contact)).to eq contact
      end
      # DBから読み直して、contactが更新されていないこと
      it "does not update the contact's attributes" do
        contact.reload
        expect(contact.firstname).to_not eq 'Larry'
        expect(contact.lastname).to eq 'Smith'
      end
      # editがレンダリングされること
      it "re-renders the #edit template" do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    # 元々こういうデータが永続化されていたとする
    let(:contact) { create(:contact, firstname: 'Lawrence', lastname: 'Smith') }

    before do
      allow(contact).to receive(:destroy).and_return(true)
      delete :destroy, id: contact
    end
    # DBに無いこと
    it "deletes the contact from the database" do
      expect(Contact.exists? contact).to be_false
    end
    # 成功したらリダイレクトして一覧に戻ること
    it "redirects to users#index" do
      expect(response).to redirect_to contacts_path
    end
  end
end
