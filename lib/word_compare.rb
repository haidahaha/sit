require 'nokogiri'
require 'open-uri'
require 'matrix'

class WordCompare 

 def self.compare_sets (set1, set2)
    str1 = ""
    str2 = ""
    
    set1.each do |element|
       str1 += "&inset[]=#{element}"
    end
    
    set2.each do |element|
       str2 += "&inatr[]=#{element}"
    end
    url = "http://www.mechanicalcinderella.com/index.php?#{str1[1..-1]}#{str2}&domena=#results"
    puts url
    page = Nokogiri::HTML(open(url))
    table = Array.new
    (page.xpath("//td/text()")).each do |element| 
      table.push((element.text == "INF") ? "5" : element.text)
    end  

    matrix = Matrix.build(set2.length, set1.length) {|row, col| table[(row+1)*set1.length+col+1].to_f}
    
    return matrix
 end

end

