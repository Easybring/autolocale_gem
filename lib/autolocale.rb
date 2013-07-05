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
    File.open(file2, "w") do |out|
      YAML.dump(newhash, out)
    end
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

  private

  def self.compare_yaml(f1, f2, path = [])
    f1.each do |key, value|
      # check if f2.key equals f1.key
      unless f2.key?(key)
        $issues << ["Missing translation", path.join(".") + "." + key]
        next
      end

      # check if f1.key's value-type equals f2.key's value-type
      unless value.is_a?(f2[key].class)
        c = path
        $issues << ["Wrong value type (#{value.class.name} vs #{f2[key].class.name})", path.join(".") + "." + key]
        next
      end

      # go deeper
      if value.is_a?(Hash)
        compare_yaml(value, f2[key], (path + [key]))
        next
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