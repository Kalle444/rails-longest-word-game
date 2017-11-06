require 'open-uri'
require 'json'
require 'time'


class GamesController < ApplicationController

  def game
    @grid_array = generate_grid(9)
    @grid = @grid_array.join('')
    @time_start = Time.now
  end

  def score
    @attempt = params[:attempt]
    @time = time(params[:time_start]).to_i
    @answer = json_answer(params[:attempt])
    @compare_words = evaluate_letter(params[:attempt], params[:grid])
    @score = calculated_score(params[:attempt], @time)
    @result = answer(@answer, @time, @score, @compare_words)
  end

private

  def time(start_time)
    start = Time.parse(start_time)
    Time.now - start
  end

  def generate_grid(grid_size)
    word = []
    grid_size.times do | |
      letter = ('A'..'Z').to_a.sample
      word << letter
    end
    return word
  end

  def evaluate_letter(attempt, grid)
    attempt_array = attempt.upcase.scan(/\w/)
    grid_sort = grid.scan(/\w/).sort
    attempt_array.uniq.all? do |letter|
      grid_sort.count(letter) >= attempt_array.count(letter)
    end
  end

  def calculated_score(attempt, time)
    max_score = 100
    min_score = 1
    if (max_score - time) >= min_score
      (max_score - time) * attempt.length
    else
      min_score * attempt.length
    end
  end

  def json_answer(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    JSON.parse(open(url).read)
  end

  def answer(answer, time, score, comp)
    if answer["found"] == false
      { time: time, score: 0, message: "not an english word" }
    elsif comp == false
      { time: time, score: 0, message: "not in the grid" }
    else
      { time: time, score: score, message: "well done" }
    end
  end

end



