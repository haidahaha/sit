require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'matrix'

class WordCompare 

 def self.compare_sets (interests, topics)
    str1 = ""
    str2 = ""
    
    interests.each do |element|
       str1 += "&inset[]=#{CGI::escape(element)}"
    end
    
    topics.each do |element|
       str2 += "&inatr[]=#{CGI::escape(element)}"
    end
    url = "http://www.mechanicalcinderella.com/index.php?#{str1[1..-1]}#{str2}&domena=#results"
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
 
 #returns number
 def self.is_relevant (matrix, n)
    if n > matrix.column_size
       n = matrix.column_size
    end
    row_mean = Array.new

    (matrix.row_vectors ).each do |row|
      row = row.sort()[0..n-1] #First n elements
      row.del("10")
      next if row.size == 0
      
      row_mean << row.inject{ |sum, el| sum + (el==10)? 0:el }.to_f / row.size     
    end
    row_mean = row_mean.inject{ |sum, el| sum + el }.to_f / row_mean.size 
 end
end

#arr1 = ["Inverse Relation","Robert Morris"]
#arr2 = ["Hackzurich","Swisscom"]

#matr = WordCompare.compare_sets(arr1,arr2)
#judge = WordCompare.is_relevant(matr,2)
