#!/usr/bin/env ruby

require 'json'

class FixedWidthToCSV
  def self.parse(data_file, data_definition_file, output_file_name)
    puts "reading definition file..."
    data_definition = JSON.parse( File.read(data_definition_file) )

    puts "creating output file for writing..."
    output_file = File.open(output_file_name, 'w')

    puts "generating headers..."
    output_file.puts( generate_headers(data_definition) )
    
    puts "writing rows..."
    file = File.open(data_file, 'r')
    while !file.eof?
       row = file.readline.strip
       next if row == ""
       output_file.puts( generate_row(data_definition, row) )
    end

    puts "closing output file..."
    output_file.close
  end
  
  def self.generate_headers(data_definition)
    data_definition.keys.join(',')
  end

  def self.generate_row(data_definition, row)
    row.unpack(data_definition.values.map{|v| "A#{v}"}.join).join(',')
  end
end

FixedWidthToCSV.parse(ARGV[0], ARGV[1], ARGV[2])
