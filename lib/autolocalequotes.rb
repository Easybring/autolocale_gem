#!/usr/bin/env ruby
# encoding: UTF-8

require 'yaml'
require_relative 'hash'

class AutoLocale

  def self.compare(file1, file2)
    abort "\033[31mSyntax error\033[0m" if file1.nil? || file2.nil?
    f1 = YAML.load_file(file1) # gets a hash from yaml file
    f2 = YAML.load_file(file2)
    $issues = []
    compare_yaml(f1.first[1], f2.first[1])
    if $issues.empty?
      puts "\033[32mNo problems found!\033[0m"
    else
      show_issues
    end
  end

  def self.automerge(file1, file2)
    abort "\033[31mSyntax error\033[0m" if file1.nil? || file2.nil?
    f1 = YAML.load_file(file1)
    f2 = YAML.load_file(file2)
    puts "\033[32mAuto merging missing translations into #{File.basename(file2)} ...\033[0m"
    newhash = merge_files(f1.clone, f2.clone)
    append_stuff(newhash, "๛๛๛&๛๛๛ ")
    File.open(file2, "w") do |out|
      YAML.dump(newhash, out)
    end
    text = File.read(file2)
    replaced = text.gsub("๛๛๛&๛๛๛ ", "")
    File.open(file2, "w") { |f| f << replaced }
    puts "\033[32mdone!\033[0m"

    $issues = []
    f1 = YAML.load_file(file1)
    f2 = YAML.load_file(file2)

    compare_yaml(f1.first[1], f2.first[1]) # first[1] skips the locale ("en:")

    count = $issues.size.to_i
    if count > 0
      puts "\033[31mThere are some more issues:\033[0m"
      show_issues
    else
      puts "\033[32mNo further issues found!\033[0m"
    end
  end

  def self.untranslated(file1, file2)
    abort "\033[31mSyntax error\033[0m" if file1.nil? || file2.nil?
    f1 = YAML.load_file(file1) # gets a hash from yaml file
    f2 = YAML.load_file(file2)
    $issues = []
    find_untranslated(f1.first[1], f2.first[1])
    if $issues.empty?
      puts "\033[32mNo problems found!\033[0m"
    else
      show_issues
    end
  end

  private

  def self.compare_yaml(f1, f2, path = [])
    f1.each do |key, value|
      # check if f2.key equals f1.key
      unless f2.key?(key)
        $issues << ["Missing translation", path.clone.push(key).join(".")]
        next
      end

      # check if f1.key's value-type equals f2.key's value-type
      unless value.is_a?(f2[key].class)
        $issues << ["Wrong value type (#{value.class.name} vs #{f2[key].class.name})", path.clone.push(key).join(".")]
        next
      end

      # go deeper
      if value.is_a?(Hash)
        compare_yaml(value, f2[key], (path + [key]))
        next
      end
    end
  end

  def self.find_untranslated(f1, f2, path = [])
    f1.each do |key, value|

      # check if the values are the same
      if value.to_s == f2[key].to_s && value.is_a?(f2[key].class)
        $issues << ["untranslated key", path.clone.push(key).join(".")]
        next
      end

      # go deeper
      if value.is_a?(Hash)
        find_untranslated(value, f2[key], (path + [key]))
        next
      end
    end
  end

  def self.append_stuff(hsh, stuff)
    hsh.each do |key, value|
      if value.is_a?(Hash)
        hsh[key] = append_stuff(value, stuff)
      elsif value.is_a?(String)
        hsh[key] = value + stuff
      elsif value.is_a?(Array)
        hsh[key] = value.each_index do |a|
          value[a] = value[a] + stuff if a.is_a?(String)
        end
      end
    end
  end

  def self.merge_files(f1, f2)
    loc1 = f1.first.first # e.g. 'en:'
    loc2 = f2.first.first # e.g. 'de:'
    new = {}
    new[loc2] = f1[loc1].deep_merge!(f2[loc2])
    new
  end

  def self.show_issues
    puts "\033[31m#{$issues.size} problem(s) found!\033[0m"
    error_length = $issues.collect(&:first).max_by(&:length).length
    path_length = $issues.collect(&:last).max_by(&:length).length
    puts "┌─#{("─" * error_length)}─┬─#{("─" * path_length)}─┐"
    puts "│ " + "Type of error".ljust(error_length) + " │ " + "Path".ljust(path_length) + " │"
    puts "├─#{("─" * error_length)}─┼─#{("─" * path_length)}─┤"
    $issues.each do |i|
      puts "│ " + i[0].ljust(error_length) + " │ " + i[1].ljust(path_length) + " │"
    end
    puts "└─#{("─" * error_length)}─┴─#{("─" * path_length)}─┘"
  end
end