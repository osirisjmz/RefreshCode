age = 36
#This will produce an error:
txt = "My name is John, I am " + age
print(txt) 
#The correct way:
txt = "My name is John, I am {}".format(age)
print(txt)