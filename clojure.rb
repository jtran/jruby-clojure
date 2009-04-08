# Jruby-Clojure Example Usage:
#   
#   Clojure.execute( "(first [1 2 3])" )  
#     => 1
#
#   Clojure.execute( "(pp (rest [1 2 3]))" )  
#     => "(2 3)"
# 
#   Requirements: expects boot.clj in local directory
#
  
%w[ java.io.ByteArrayInputStream
    java.io.BufferedReader
    java.io.InputStreamReader  
    clojure.lang.Compiler ].each { |c| include_class c }   
   
class Clojure
  
  BOOT_CLJ = File.join File.dirname(__FILE__), 'boot.clj' 
  
  class << self
    
    private
    
    def load( str_clj ) 
      java_string = java.lang.String.new( str_clj + "\n")
      stream = ByteArrayInputStream.new( java_string.getBytes )
      rdr = BufferedReader.new( InputStreamReader.new( stream )) 
      Compiler.load( rdr )
    end
    
    def prelude_clj 
      <<-'EOS'
        (import (quote (java.io BufferedWriter OutputStreamWriter ByteArrayOutputStream))) 
        (defn pp [form]
          (let [bytearray (new ByteArrayOutputStream )]
          	(with-open wtr (new BufferedWriter (new OutputStreamWriter bytearray "US-ASCII"))
          	  (. clojure.lang.RT (print form wtr)))
          	((memfn toString) bytearray)))  		
      EOS
    end     
    
    def boot_clj
      IO.read BOOT_CLJ 
    end
    
    def prepare!
      init!
      test
    end  
    
    public 

    def execute( str_clj ) 
      load str_clj 
    end
    
    def init!
      load( boot_clj + prelude_clj )
    end 
      
    def test               
      [   
          "Clojure.execute( '(first [1 2 3])' ) == 1", 
          "Clojure.execute( '(pp (rest [1 2 3]))' ) == '(2 3)'" 
      ].each { | t | raise( "Test failed: " + t ) unless eval t }
    end      
    
  end # class << self  

  prepare! 
  
end # class Clojure       
       