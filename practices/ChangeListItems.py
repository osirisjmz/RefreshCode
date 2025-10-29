thislist = ["apple", "banana", "cherry", "orange", "kiwi", "melon", "mango"]
thislist[1:3] = ["blackcurrant", "watermelon"]
print(thislist)
#result: ['apple', 'blackcurrant', 'watermelon', 'orange', 'kiwi', 'melon', 'mango']
thislist2 = ["apple", "banana", "cherry"]
thislist2[1:3] = ["watermelon"]
print(thislist2)
#result: ['apple', 'watermelon']

thislist3 = ["apple", "banana", "cherry"]
thislist3.insert(2, "watermelon")
print(thislist3)
#result: ['apple', 'watermelon', 'banana', 'cherry']