class GamesController < ApplicationController
  require 'open-uri'

  def new
    @start_time = Time.now
    @grid = (1..params[:grid_size].to_i).map { ('a'..'z').to_a[rand(26)] }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score
    start_time = params[:start_time].to_i
    end_time = Time.now
    grid = params[:grid].split(" ")
    attempt = params[:attempt].downcase
    # attempt = params[:attempt].downcase.split("")
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    @result = result


  end

  def score_and_message(attempt, grid, time)
    if included?(attempt, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        @message = "Your score is #{score}, well done."
      else
        @message = "Your score is 0 as #{attempt}  is not an English word"
      end
    else
      @message = "Your score is 0 as #{attempt}  is not in the grid"
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
