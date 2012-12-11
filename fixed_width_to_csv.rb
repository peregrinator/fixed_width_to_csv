#!/usr/bin/env ruby

require 'json'

class FixedWidthToCSV
  attr_accessor :data_file, :data_definition, :output_file_name, :formatters, :values_needing_format

  def initialize(data_file, data_definition_file, output_file_name)
    @data_file = data_file

    puts "reading definition file..."
    @data_definition = JSON.parse( File.read(data_definition_file) )

    @output_file_name = output_file_name

    puts "determining values needing format"
    @values_needing_format = @data_definition.map{|d| d.length > 1 ? [d, @data_definition.index(d)] : nil}.compact

    @formatters = Formatters.new
    
    parse
  end

  def parse
    puts "creating output file for writing..."
    @output_file = File.open(@output_file_name, 'w')

    puts "generating headers..."
    @output_file.puts( generate_headers )

    puts "writing rows..."
    file = File.open(@data_file, 'r')
    while !file.eof?
      row = file.readline.strip
      next if row == ""

      row = generate_row(row)
      row = format_row(row)
      @output_file.puts( row.join(',') )
    end

    puts "closing output file..."
    @output_file.close
  end
  
  def generate_headers
    @data_definition.map{|d| d.keys.first}.flatten.join(',')
  end

  def generate_row(row)
    values = @data_definition.map{|d| d.values.first}
    row.unpack(values.map{|v| "A#{v}"}.join)
  end

  def format_row(row)
    @values_needing_format.each do |data, index|
      current_format = data["format"]
      new_format = data["convert_to"]
      value = row[index]
     
      new_value = @formatters.send("#{current_format}_to_#{new_format}", value)

      row[index] = new_value
    end
    row
  end
end

class Formatters
  def mddyy_to_mmddyy(value)
    value = value.strip
    if value.length == 6
      value
    else
      "0#{value}"
    end
  end

  def mmyy_to_mmddyy(value)
    "#{value[0..1]}01#{value[2..3]}"
  end
end

FixedWidthToCSV.new(ARGV[0], ARGV[1], ARGV[2]).parse
