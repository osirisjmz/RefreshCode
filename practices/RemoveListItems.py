thislist = ["apple", "banana", "cherry"]
thislist.remove("banana")
print(thislist)
#result: ['apple', 'cherry']

thislist2 = ["apple", "banana", "cherry"]
thislist2.pop(1)    #remove item at index 1
print(thislist2) 
#result: ['apple', 'cherry']

thislist3 = ["apple", "banana", "cherry", "orange", "kiwi", "melon", "mango"]
thislist3.remove("kiwi")
print(thislist3)
#result: ['apple', 'banana', 'cherry', 'orange', 'melon', 'mango']    
# 
thislist4 = ["apple", "banana", "cherry"]
del thislist4[0]    #remove item at index 0
print(thislist4)
#result: ['banana', 'cherry']

thislist = ["apple", "banana", "cherry"]
thislist.clear()
print(thislist)
#blank list: []

