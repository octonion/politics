#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

congress_id = ARGV[0]
session_id = ARGV[1]

print "Congress #{congress_id}, session #{session_id} -"

base_url = "http://www.senate.gov/legislative/LIS/roll_call_lists/vote_menu_#{congress_id}_#{session_id}.htm"

agreed = CSV.open("csv/agreed_#{congress_id}_#{session_id}.csv", "w")

header = ["congress_id", "session_id",
          "vote", "vote_url",
          "result",
          "question_description",
          "reference_issue", "reference_issue_url",
          "issue", "issue_url",
          "date"]

agreed << header

path = '//td[2][text()="Agreed to"]/..'

page = agent.get(base_url)

found = 0
page.parser.xpath(path).each do |tr|

  row = [congress_id, session_id]

  tr.xpath("td").each_with_index do |td,j|

    text = td.text.gsub("&nbsp;", " ").scrub.strip rescue nil

    case j
    when 0,3

      a = td.xpath("a")
      relative_url = a.first.attributes["href"].to_s rescue nil
      text_url = a.inner_text.gsub("&nbsp;", " ").scrub.strip rescue nil
      full_url = URI.join(base_url, relative_url).to_s rescue nil
      
      row += [text_url, full_url]

    when 2

      a = td.xpath("a")
      relative_url = a.first.attributes["href"].to_s rescue nil
      text_url = a.inner_text.gsub("&nbsp;", " ").scrub.strip rescue nil
      full_url = URI.join(base_url, relative_url).to_s rescue nil

      row += [text, text_url, full_url]
      
    else
      
      row += [text]
      
    end

  end
  
  agreed << row
  found += 1
end

agreed.close
print " #{found}\n"
