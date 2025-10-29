print("Osiris")
print('Osiris')

print("It's alright")
print("He is called 'Johnny'")
print('He is called "Johnny"')

a = " Hello, Osiris " 
print(a)
print(a.strip()) # returns "Hello, Osiris"
print(a.lower()) # returns " hello, osiris "
print(a.upper()) # returns " HELLO, OSIRIS "
print(a.replace("H", "J")) # returns " Jello, Osiris "
print(a.split(",")) # returns [' Hello', ' Osiris ']
print(a.split(" ")) # returns ['','Hello,', 'Osiris', '']
print(a.split("o")) # returns [' Hell', ', Osiris ']
print(a.split("l")) # returns [' He', '', 'o, Osiris ']
print(a.split("i")) # returns [' Hello, Os', 'r', 's ']
print(a.split("s")) # returns [' Hello, O', 'iri', '']
print(a.split("e")) # returns [' H', 'llo, Osiris ']

a = """1- Lorem ipsum dolor sit amet,
consectetur adipiscing elit,
sed do eiusmod tempor incididunt
ut labore et dolore magna aliqua."""
print(a)

b = '''2 - Orale ipsum dolor sit amet,
consectetur adipiscing elit,
sed do eiusmod tempor incididunt
ut labore et dolore magna aliqua.'''
print(b)