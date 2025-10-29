thislist = ["apple", "banana", "cherry"]
i = 0 #index number
while i < len(thislist):
    print(thislist[i])
    i = i + 1
#result: apple
#banana
#loop to go through all the index numbers


"""Looping Using List Comprehension
List Comprehension offers the shortest syntax for looping through lists:"""
thislist2 = ["apple", "banana", "cherry"]
print("\n")

print("List 2:")
[print(x) for x in thislist2]
#result: apple
