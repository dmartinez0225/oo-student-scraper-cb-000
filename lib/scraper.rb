require 'open-uri'
require 'pry'
require 'nokogiri'

class Scraper

  def self.scrape_index_page(index_url)
    html = open(index_url)
    doc = Nokogiri::HTML(html)
    students = []
    doc.css("div.roster-cards-container").each do |part|
      part.css(".student-card a").each do |student|
        profile_url = "#{student.attr('href')}"
        location = student.css('.student-location').text
        name = student.css('.student-name').text
        students << {name: name, location: location, profile_url: profile_url}
      end
    end
    students
  end

  def self.scrape_profile_page(profile_url)
    page = open(profile_url)
    profile = Nokogiri::HTML(page)
    student = {}
    links = profile.css(".social-icon-container").children.css("a").map { |el| el.attribute('href').value}
    links.each do |link|
      if link.include?("linkedin")
        student[:linkedin] = link
      elsif link.include?("github")
        student[:github] = link
      elsif link.include?("twitter")
        student[:twitter] = link
      else
        student[:blog] = link
      end
    end
    student[:profile_quote] = profile.css(".profile-quote").text if profile.css(".profile-quote")
    student[:bio] = profile.css("div.bio-content.content-holder div.description-holder p").text if profile.css("div.bio-content.content-holder div.description-holder p")
    student
  end
end
