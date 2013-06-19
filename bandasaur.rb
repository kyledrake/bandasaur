class Bandasaur < Sinatra::Base

  before do
    puts params.inspect if self.class.development?
    init_user
    session[:locale] = params[:locale] if params[:locale]
  end

  get '/genres.json' do
    content_type :json
    Genre.all_with_tracks(params[:track_count] || 0).to_hash.to_json
  end

  get '/' do
    @genres = Genre.all_with_tracks
    @countries = Country.all order: 'name'
    erubis :index
  end

  get '/tracks/?' do
    erubis :'tracks/index'
  end

  get '/tracks/search.json' do
    content_type 'application/json'
    save_search_params
    slugs = Track.search params[:search]
    puts slugs.inspect
    slugs.to_json
  end

  get '/tracks/:slug.json' do
    content_type 'application/json'
    @track = Track.get params[:slug]
    @track.to_json
  end

  get '/sessions/new' do
    redirect '/' if current_user
    erubis :'sessions/new'
  end

  post '/sessions' do
    @user = User.login params['email'], params['password']
    if @user
      init_session_for @user
      redirect '/'
    else
      @not_successful = true
      erubis :'sessions/new'
    end
  end

  get '/sessions/logout' do
    delete_session
    redirect '/'
  end

  get '/users/new' do
    redirect '/' if current_user
    title 'Get ready to rock.'
    @genres = Genre.all_with_tracks
    erubis :'users/new'
  end

  get '/users/:id' do
    @user = User.get params[:id].split('-')[0]
    erubis :'users/show'
  end

  post '/users' do
    raise User::RegistrationError, 'Invalid user parameters' unless @user.valid?
    raise User::RegistrationError, 'No recaptcha verification' unless session['recaptcha_verified']
    raise User::RegistrationError, 'Cannot create user while logged in as another user' unless current_user
    @user = User.save
    init_session_for @user
    session['recaptcha_verified'] = false
    redirect '/'
  end

  post '/validate/:model_name' do
    @model = eval(params['model_name'].capitalize).new params[params['model_name']]
    @model.valid?

    # We can't submit the recaptcha twice, so we just grant a create token instead.
    if session['recaptcha_verified'] || recaptcha_valid?
      session['recaptcha_verified'] = true
    else
      @model.errors.add :generic, 'Please fill out the CAPTCHA correctly'
    end

    message = ''
    if @model.errors.length > 0
      message += "Please correct the following errors:\n<ul>"
      @model.errors.collect {|p| "<li>#{p.first}</li>"}.each {|e| message += e}
      message += "</ul>"

      puts "MESSAGE: #{message.inspect}"
      message
    end
  end

  private

  def search_params
    return nil if session[:search].nil?
    @_search_params ||= Hashie::Mash.new JSON.parse(session[:search], symbolize_names: true)
  end

  def save_search_params
    return nil if params[:search].nil?
    session[:search] = params[:search].to_json
  end

  def init_user
    @_current_user = User.get session['user_id'] if session['user_id']
  end

  def current_user
    @_current_user
  end

  def init_session_for(user)
    session['user_id'] = user.id
  end

  def delete_session
    session['user_id'] = nil
  end

end
