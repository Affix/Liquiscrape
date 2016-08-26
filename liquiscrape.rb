#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'


max_page = 39
url = "http://www.lediypourlesnuls.com"

def to_percent(value)
  value = value.to_f
  ((value * 100) / 10).round(2)
end

def ingredient_string(split_values)
  string = []
  max = split_values.count - 1
  (2..max).each do |i|
    string << split_values[i]
  end
  string.join(" ")
end

(1..max_page).each do |page_number|
  doc = Nokogiri::HTML(open("#{url}/page/#{page_number}"))
  articles = doc.css("h2.article-title")
  puts "found #{articles.count} recipes on page #{page_number}"
  articles.each do |recipe|
    link = recipe.css("a")
    page = Nokogiri::HTML(open(link.at("a")['href']))
    ingredients = page.css("li.wpurp-recipe-ingredient") #doc.xpath("//li[@class='wpurp-recipe-ingredient']/li")
    title = page.css("h1.article-title")
    manuf_tag = page.css("li.wpurp-recipe-tags-fabricant")
    manuf = manuf_tag.css("span.recipe-tags")

    Dir.mkdir("recipes/#{manuf.text.strip}") unless File.exists? "recipes/#{manuf.text.strip}"
    ## Recipe Title
    File.open("recipes/#{manuf.text.strip}/#{title.text}.txt", "w+") do |f|
      ingredients.each do |ingredient|
        breakdown = ingredient.text.split(" ")
        if ingredient.text.include? "Base"
          f.write "#{to_percent(ingredient.text.split(" ")[0])} Base\n"
          break
        else
          f.write "#{to_percent(ingredient.text.split(" ")[0])}% #{ingredient_string(breakdown)}\n"
        end
      end
    end
    puts "Created #{manuf.text.strip}/#{title.text}.txt"
  end
end
