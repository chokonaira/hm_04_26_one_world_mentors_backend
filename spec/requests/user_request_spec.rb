require 'rails_helper'

RSpec.describe "User", type: :request do
  include Helpers
  let(:auth_headers){login}
  
  describe "GET /index" do
    it "returns welcome message" do
      get '/'
      expect(response.body['message']).to include('message')
    end
  end

  context 'user_signup' do
    it 'creates a new user' do
      headers = { 'ACCEPT' => 'application/json' }
      post '/signup', params: { user: { first_name: 'Julius', last_name: 'Ngwu', email:'julius@1', password:'julius@@1', user_type:'mentee' } }, headers: headers
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:created)
    end
    it 'fails to creates a user' do
      headers = { 'ACCEPT' => 'application/json' }
      post '/signup', params: { user: { firkst_name: 'Julius', last_name: 'Ngwu', email:'julius@1', password:'julius@@1', user_type:'mentee' } }, headers: headers
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response.body).to include('error')
    end
  end

  context 'update_user' do
    it 'update a user profile' do
      user = User.create(first_name: 'Julius', last_name: 'Ngwu', email:'julius@1', password:'julius@@1', user_type:'mentee' )
      patch "/user/profile/#{user.id}", params: { first_name:'Ebuka', last_name: 'Ngwu', email:'ebuka@1', user_type:'mentor' }.to_json, headers: auth_headers
      
      updated_user = JSON.parse(response.body)
      expect(updated_user["first_name"]).to eq("Ebuka")
      expect(updated_user["email"]).to eq("ebuka@1")
      expect(updated_user["user_type"]).to eq("mentor")
    end
    it 'should return default profile' do
      user = User.create(first_name: 'Julius', last_name: 'Ngwu', email:'julius@1', password:'julius@@1', user_type:'mentee' )
      patch "/user/profile/#{user.id}", params: { first_name:'', last_name: '', email:'', user_type:'' }.to_json, headers: auth_headers
      expect(response.body).to include('error')

    end
  end
  context 'get single user' do
    it 'get a specific user details' do
      user = FactoryBot.create(:user)
      get "/user/#{user.id}", headers: auth_headers
      
      data = JSON.parse(response.body)
      expect(data["data"]["first_name"]).to eq(user.first_name)
      expect(data["data"]["email"]).to eq(user.email)
      expect(data["data"]["user_type"]).to eq(user.user_type)

    end
    it 'should fail to return user' do
      get "/user/99999", headers: auth_headers
      data = JSON.parse(response.body)

      expect(data["message"]).to eq("User with Id: 99999 is not found")

    end
  end

end
