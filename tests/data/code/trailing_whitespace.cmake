
cmake_minimum_required(VERSION 3.29...3.31)

if(TRUE)     	 	 	
  message(STATUS "Lorem ipsum dolor sit amet.")   
endif()   

set( 	
  foobar [[ 	
  		
]])

set(files 
	asdf
  	fdsa 	
    " " 	
    # asdf 	
    #[[
    		 	
    ]]	 
 
    some more items  
    " 
  content  	   
    "  	
)  

set(fileTypes txt;png;zip;cmake;)   

  	set(content [[asdf_1;asdf_2  	
asdf_3;asdf_4	  
asdf_5;asdf_6  
asdf_7
	
  	
asdf_8
]])
string(REGEX REPLACE "[ \t]+\n" "*\n" content "${content}")
message(STATUS "'${content}'")

	  

  