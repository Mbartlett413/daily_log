# frozen_string_literal: true

require 'date'
require 'pry'
require 'json'

JSON_FILE_NAME = "day_log_#{Time.now.strftime('%Y')}.json".freeze

# DayLog class
class DayLog
  def initialize
    find_or_create_file
    @new_json = json_file
  end

  def welcome_message
    puts('Welcome to DayLog')
    puts("Today is #{current_date.strftime('%m/%d/%Y')}")
    puts("Week Number #{current_date.strftime('%W')}/56")
    log_break
    start_service
  end

  def start_service
    puts('What would you like to do? LOG or READ?')
    user_input = gets.chomp.downcase
    if user_input == 'log'
      create_log
    elsif user_input == 'read'
      read_log
    else
      puts 'enter LOG or READ'
      start_service
    end
  end

  def log_break
    puts('------------------------')
  end

  private

  def create_log
    puts('what did you work on today?')
    log_day = gets.chomp
    puts('what are your ongoing task/s?')
    log_ongoing = gets.chomp
    puts('what are your goals for tomorrow?')
    log_goals = gets.chomp
    log = log_structure(log_day, log_ongoing, log_goals)
    log_break
    puts log
    puts('Is this correct? (y/n)')
    confirm = gets.chomp.downcase
    if confirm == 'y'
      log_to_file(log)
    else
      create_log
    end
  end

  def read_log
    puts("Current Entries: #{@new_json.keys}")
    puts('Which week(s) would you like to read? ONE, ALL, RANGE')
    log_break
    requested_week = selected_week(gets.chomp)
    return if requested_week.nil?

    requested_week.each do |k, v|
      puts "Week: #{k}"
      v.each do |vl|
        puts "#{vl['date']}:: you worked on #{vl['achievement']} which was part of #{vl['ongoing']}. My goal was #{vl['goals']}"
      end
    end
  end

  def selected_week(week_request)
    case week_request.downcase
    when 'one'
      puts('Select week')
      week = gets.chomp
      return if validate_input(week) == false

      { "#{week}": @new_json[week.to_s] }
    when 'all'
      @new_json
    when 'range'
      puts('Starting Week?')
      start_week = gets.chomp
      return if validate_input(start_week) == false

      puts('Ending Week?')
      end_week = gets.chomp
      return if validate_input(end_week) == false

      range = (start_week..end_week).sort

      range.each_with_object({}) do |wk, object|
        object[wk] = @new_json[wk.to_s]
      end
    end
  end

  def validate_input(input)
    return false if input.nil?

    if @new_json.keys.include?(input.to_s)
      true
    else
      puts('Invalid Week')
      false
    end
  end

  def log_to_file(log)
    @new_json[week_of_year] = [] if @new_json[week_of_year].nil?
    @new_json[week_of_year].push(log)
    File.open(JSON_FILE_NAME, 'w') do |file|
      file.write(JSON.pretty_generate(@new_json))
    end
  end

  def log_structure(log_day, log_ongoing, log_goals)
    {
      "date": current_date.strftime('%m/%d/%Y'),
      "achievement": log_day,
      "ongoing": log_ongoing,
      "goals": log_goals
    }
  end

  def current_date
    Time.now
  end

  def week_of_year
    @week_of_year ||= current_date.strftime('%W')
  end

  def json_file
    @_json_file = JSON.parse(read_file)
  end

  def read_file
    File.read(JSON_FILE_NAME)
  end

  def find_or_create_file
    return if File.exist?(JSON_FILE_NAME)

    initial = { "#{week_of_year}": [] }
    File.new(JSON_FILE_NAME, 'w')
    File.open(JSON_FILE_NAME, 'w') do |file|
      file.write(initial.to_json)
    end
  end
end

# perform
DayLog.new.welcome_message
