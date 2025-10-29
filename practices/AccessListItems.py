thislist = ["apple", "banana", "cherry"]
print(thislist[0])
#result: apple
thislist[1] = "blackcurrant" #change item 1
#result: ['apple', 'blackcurrant', 'cherry']
print(thislist)

thislist4 = ["apple", "banana", "cherry", "orange", "kiwi", "melon", "mango"]
print(thislist4[2:5]) #items from index 2 to 4
#result: ['cherry', 'orange', 'kiwi']

print(thislist4[:4]) #items from beginning to index 3
#result: ['apple', 'banana', 'cherry', 'orange']

print(thislist4[2:]) #items from index 2 to end
#result: ['cherry', 'orange', 'kiwi', 'melon', 'mango']

print(thislist4[-4:-1]) #items from index -4 (included) to
#-1 (not included)
#result: ['kiwi', 'melon', 'mango'] 

thislist5 = ["apple", "banana", "cherry"]
if "apple" in thislist5:
    print ("Yes, 'apple' is in the fruits list")

    """Piensa así:

Inicio (1) → entra.

Fin (3) → no entra.

Todo entre ellos (2) → entra.

Más mini-ejemplos rápidos:

a[1:2] → solo índice 1

a[1:3] → índices 1 y 2

a[0:len(a)] → toda la lista

Si quieres incluir un elemento con índice k como final, usa k+1: a[i:k+1].

Y en asignación de slice:

El tramo seleccionado puede ser reemplazado por cualquier número de elementos (más, menos o igual). Python ajusta la lista."""
