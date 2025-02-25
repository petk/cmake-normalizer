cmake_minimum_required(VERSION 3.29...3.31)

set (variable true)

set(variable_2)

set(variable_3 #[[bracket comment]])

set(variable_4
  # line comment

  #[[
    bracket comment
  #]]
)

set(variable_5 PARENT_SCOPE)

set(fileTypes txt;png;zip;cmake;)

# TODO: It seems that set() can also set the [ and ] characters. See list manual
# page in the intro some description and test this further. There it says
set(specialCharacters [a] b "\\")
message(STATUS "${specialCharacters}")
list(POP_FRONT specialCharacters firstItem)
message(STATUS "${firstItem}")
# Here the first item has unclosed opening square bracket character (which is
# according to documentation wrong, but CMake doesn't seem to emit warnings.
# However, the second output here won't work properly and will set entire
# list to the output variable <firstItem>.
set(specialCharacters [a b "\\")
message(STATUS "${specialCharacters}")
list(POP_FRONT specialCharacters firstItem)
message(STATUS "${firstItem}")
