require 'sinatra/base'
require 'battleships'


class BattleshipsWeb < Sinatra::Base

  # def self.player_1
  #   @@player_1
  # end

  # def self.player_2
  #   @@player_2
  # end

  enable :sessions

  $game = Game.new(Player, Board)

  get '/' do
    erb :index
  end

  get '/register' do
    erb :form
  end

  post '/name' do
    session[:name] = params[:name]
    @player = session[:name]
    $players << @player
    redirect '/register' if session[:name] == ""
    redirect '/welcome'
  end

  $players = []

  get '/welcome' do
    if $players.count == 1
      @player_1 = session[:name]
      session[:player] = :player_1
      redirect '/game_1' if $players.count == 1
    else
      @player_2 = session[:name]
      session[:player] = :player_2
      redirect '/game_2' if $players.count == 2
    end
    # redirect '/game' if $players.count == 2
    erb :welcome
  end


  get '/game_1' do
    erb :game_1
  end

  get '/game_2' do
    erb :game_2
  end

  post '/game_1' do
    @parameters = params
    $game.player_1.place_ship(Ship.send(@parameters[:ship].to_sym), @parameters[:coordinate].to_sym, @parameters[:direction].to_sym)

    redirect '/gameplay_1' if $game.player_1.board.ships.count > 1

    erb :game_1
  end

  post '/game_2' do
    @parameters = params
    $game.player_1.place_ship(Ship.send(@parameters[:ship].to_sym), @parameters[:coordinate].to_sym, @parameters[:direction].to_sym)

    redirect '/gameplay_2' if $game.player_1.board.ships.count > 1

    erb :game_2
  end


  get '/gameplay_1' do
    place_computer_ships
    erb :gameplay_1
  end


  get '/gameplay_2' do
    place_computer_ships
    erb :gameplay_2
  end

  post '/gameplay_1' do
    @coordinate = params[:coordinate]
    @player_1_result = $game.player_1.shoot(@coordinate.to_sym)
    @player_2_result = $game.player_2.shoot(generate_computer_coordinates)
    redirect '/winner' if $game.has_winner?
    erb :gameplay_1
  end

  post '/gameplay_2' do
    @coordinate = params[:coordinate]
    @player_1_result = $game.player_1.shoot(@coordinate.to_sym)
    @player_2_result = $game.player_2.shoot(generate_computer_coordinates)
    redirect '/winner' if $game.has_winner?
    erb :gameplay_2
  end

  get '/winner' do
    erb :winner
  end

  def place_computer_ships
    $game.player_2.place_ship(Ship.send(:submarine), :A2)
    $game.player_2.place_ship(Ship.send(:destroyer), :J2, :vertically)
    $game.player_2.place_ship(Ship.send(:cruiser), :A6)
    $game.player_2.place_ship(Ship.send(:battleship), :F3, :vertically)
    $game.player_2.place_ship(Ship.send(:aircraft_carrier), :J4, :vertically)
  end


  $coordinate_array = []


  def generate_computer_coordinates
    coordinate = [*('A'..'J')].shuffle[1,1].join + [*('1'..'10')].shuffle[1,1].join
    coordinate_skipper(coordinate)
    coordinate.to_sym
  end

  def coordinate_skipper(coordinate)
    if $coordinate_array.include?(coordinate)
      generate_computer_coordinates
    else
      $coordinate_array << coordinate
    end
  end

  set :views, Proc.new { File.join(root, "..", "views") }
  # start the server if ruby file executed directly
  run! if app_file == $0

end
