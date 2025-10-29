thislist = ["apple", "banana", "cherry"]
thislist.append("orange")
print(thislist)
#result: ['apple', 'banana', 'cherry', 'orange']

thislist2 = ["apple", "banana", "cherry"]
thislist2.insert(1, "orange")
print(thislist2)
#result: ['apple', 'orange', 'banana', 'cherry']

thislist3 = ["apple", "banana", "cherry"]
tropical = ["mango", "pineapple", "papaya"] 
thislist3.extend(tropical)
print(thislist3)
#result: ['apple', 'banana', 'cherry', 'mango', 'pineapple', 'papaya']

thislist4 = ["apple", "banana", "cherry"]
thislist4.extend(["orange", "kiwi", "melon"])
print(thislist4)
#result: ['apple', 'banana', 'cherry', 'orange', 'kiwi', 'melon']


thislist5 = ["apple", "banana", "cherry"]
thistuple = ("orange", "kiwi", "melon")
thislist5.extend(thistuple)
print(thislist5)
#result: ['apple', 'banana', 'cherry', 'orange', 'kiwi', 'melon']

             