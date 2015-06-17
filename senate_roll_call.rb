#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

congress_num = ARGV[0]
session_num = ARGV[1]

print "Congress #{congress_num}, session #{session_num} -"

url = "http://www.senate.gov/legislative/LIS/roll_call_lists/vote_menu_#{congress_num}_#{session_num}.htm"

agreed = CSV.open("csv/agreed_#{congress_num}_#{session_num}.csv", "w")

path = '//td[2][text()="Agreed to"]/..'

page = agent.get(url)

found = 0
page.parser.xpath(path).each do |tr|

  row = [congress_num, session_num]

  tr.xpath("td").each_with_index do |td,j|

    text = td.text.scrub.strip rescue nil
    row += [text]
  end
  
  agreed << row
  found += 1
end

agreed.close
print " #{found}\n"

=begin
        case j
        when 1,2
          team = td.xpath("a").first.text.scrub.strip rescue nil
          href = td.xpath("a").first.attributes["href"].to_s
          team_id = href.split("=")[1].split("&")[0] rescue nil
          href = href.scrub.strip rescue nil
          team_url = URI.join(url, href).to_s
          score = td.xpath("b").first.text rescue nil
          row += [team_id, team, team_url, score]
        when 5
          text = td.text.scrub.strip rescue nil
          score = text.split("\t")[0].scrub.strip rescue nil
          ot = text.split("\t")[1].scrub.strip rescue nil
          row += [score, ot]
        when 6
          flash_url = nil
          boxscore_url = nil
          game_id = nil
          td.xpath("a").each_with_index do |a,k|
            case k
            when 0
              href = a.attributes["href"].to_s
              game_id = href.split("=")[1]
              href = href.scrub.strip rescue nil
              flash_url = URI.join(url, href).to_s
            when 1
              href = a.attributes["href"].to_s
              href = href.scrub.strip rescue nil
              boxscore_url = URI.join(url, href).to_s
            end
          end
          row += [game_id, flash_url, boxscore_url]
        else
          row << td.text.scrub.strip rescue nil
        end
=end
