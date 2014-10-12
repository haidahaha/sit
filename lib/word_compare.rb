require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'matrix'

class WordCompare

 def self.compare_sets (interests, topics)
    str1 = ""
    str2 = ""

    #We can only calculate 5 interests for now.
    interests = interests [0..4]
    topics = topics[0..4]

    interests.each do |element|
       str1 += "&inset[]=#{CGI::escape(element)}"
    end

    topics.each do |element|
       str2 += "&inatr[]=#{CGI::escape(element)}"
    end
    url = "http://www.mechanicalcinderella.com/index.php?#{str1[1..-1].downcase}#{str2.downcase}&domena=#results"
    puts url
    page = Nokogiri::HTML(open(url))
    table = Array.new
    (page.xpath("//td/text()")).each do |element| 
      case element.text
        when "INF"
          table.push("5")
        when "NAN"
          table.push("10")  #TODO FIX - 10 is nil 
        when "no relevant data"
          table.push("10")  #TODO FIX     
        else
          table.push(element.text)
      end
    end 

    matrix = Matrix.build(topics.length, interests.length) {|row, col| table[(row+1)*interests.length+col+1].to_f}

    return matrix
 end
 
 def self.find_similar_elements (interests, topics)
    interests = interests.collect{|x| x.gsub(/[-\s]+/, "").downcase}
    topics = topics.collect{|x| x.gsub(/[-\s]+/, "").downcase}
    return interests & topics
 end
 
 #returns number
 def self.is_relevant (matrix, factor)
    if factor > 1
       facor = 1
    end
    row_mean = Array.new

    (matrix.row_vectors ).each do |row|
      n = (row.size*factor).ceil
      row = row.sort()[0..n-1] #First n elements
      row.delete(10.0)

      next if row.size == 0

      row_mean << row.inject{ |sum, el| sum + ((el==10) ? 0 : el) }.to_f / row.size
    end
    puts row_mean.size
    if row_mean.size == 0
      return 15
    end

    return row_mean.inject{ |sum, el| sum + el }.to_f / row_mean.size
 end
end
if __FILE__ == $0

people = [
          ["Inverse Relation", "Robert Morris" , "Victoria Cross" , "Venture Capital" , "Patrick Collison" , "YCombinator" , "Fireandforget"],
          ["Cocoa", "Ruby On Rails", "Startup Chile", "TEDx", "International Development", "Sustainability Reporting", "Social Business", "Corporate Social", "Soft Commodities", "Cotton", "Coffee", "Sustainability Standards", "Fundraising", "Development Coorporation", "Meetup", "Collab", "Lausanne", "Solidaridad", "F"],
          ["Ayn Al Arab", "USA", "United States", "Peoples Protection Units", "Halten Sør Trøndelag", "Sabah", "Staffan De Mistura", "Washington", "Seinen Manga", "CNN", "Ain", "CNN", "YPG", "Tatra", "Johns Hopkins University", "The New York Times", "UNO", "United Nations"],
          ["budapest", "india", "london", "sap", "consulting", "business process", "IT strategy", "SAP Integration", "Retail", "Tally Weijl", "Pre-Sales", "Business Analysis", "ERP", "Process Consulting", "Business Consulting", "Supply chain management"]
        ]

autoload(:Aylien,"./aylien.rb")        
hashtags = Aylien.get_hashtags("http://techcrunch.com/2014/10/09/microsoft-promises-its-surface-project-is-here-to-stay/")
#Remove # from Hashtag and convert CamelCase to Space separated Nouns.
hashtags = hashtags.map {|hashtag| hashtag[1..-1].gsub(/([a-z])([A-Z])/, '\1 \2')}
  puts "Hashtag: #{hashtags}"
people.each do |interests| 
  matr = WordCompare.find_similar_elements(interests, hashtags)

end

end
