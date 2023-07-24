# frozen_string_literal: true

require 'date'
require 'pry'
require 'json'

class DayLog
  def initialize; end

  def start_service
    puts('Welcome to DayLog')
    puts("Today is #{current_date.strftime('%m/%d/%Y')}")
    puts("Week Number #{current_date.strftime('%W')}/56")

    puts('What would you like to do? log or read?')
    user_input = gets.chomp.downcase
    
    if user_input == 'log'
      create_log
    elsif user_input == 'read'
      read_log
    else 
      puts "enter LOG or READ"
    end 
  end

  def create_log
    puts('what did you work on today?')
    log_day = gets.chomp

    puts('what are your ongoing task/s?')
    log_ongoing = gets.chomp

    puts('what are your goals for tomorrow?')
    log_goals = gets.chomp

    log = log_structure(log_day, log_ongoing, log_goals)
    puts log

    puts('Is this correct? (y/n)')
    confirm = gets.chomp.downcase
    if confirm == 'y'
      log_to_file(log)
    else
      puts('Exiting...')
    end
  end 

  def read_log
    json_file.each do |k,v|
      puts "Logs for week: #{k}"
      v.each do |vl|
        puts "#{vl['date']}, you worked on #{vl['achievement']} which was part of #{vl['ongoing']}. My goal was #{vl['goals']}"
      end 
    end 
  end 

  private 

  def log_to_file(log)
    find_or_create_file

    @new_json = json_file
    
    if @new_json[week_of_year].nil?
      @new_json[week_of_year] = []
    end 

    @new_json[week_of_year].push(log)

    # log to file
    File.open('day_log.json', 'w') do |file|
      file.write(@new_json.to_json)
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
    @_week_of_year ||= current_date.strftime('%W')
  end 

  def read_file
    File.read('day_log.json')
  end

  def json_file
    @_json_file = JSON.parse(read_file)
  end

  def find_or_create_file
    if File.exist?('day_log.json')
      puts('logging')
    else
      puts('hmm, file does not exist, ill create it')
      #create initial json
      File.new('day_log.json', 'w')
      initial = { "#{week_of_year}": [] } 
      File.open('day_log.json', 'w') do |file|
        file.write(initial.to_json)
      end
    end
  end
end

# perform
DayLog.new.start_service
