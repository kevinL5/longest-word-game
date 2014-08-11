require 'json'
require 'open-uri'

class LongestWordController < ApplicationController

  def game
    generate_grid
    flash[:time] = Time.now.to_f
  end

  def score
    @end_time = Time.now.to_f
    run_game
  end

  def generate_grid
    grid_size = 20
    @letters = []
    grid_size.times { @letters << ('A'..'Z').to_a.sample }
    flash[:letters] = @letters
  end

  def run_game
    @attempt = params[:query]
    @result = { time: @end_time - flash[:time].to_i, score: 0 }
    get_translation

    unless @translation
      @result[:message] = "not an english word"
    else
      if is_included?
        @result[:score] = (@attempt.length * 100 / (@end_time - flash[:time].to_i))
        @result[:message] = "well done"
      else
        @result[:message] = "not in the grid"
      end
    end
  end

  def is_included?
    @attempt.upcase.split("").all?{ |letter| flash[:letters].include? letter }
  end

  def get_translation
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{@attempt.downcase}")
    json = JSON.parse(response.read.to_s)
    @translation = json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

end
