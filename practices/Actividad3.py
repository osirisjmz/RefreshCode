#Algoritmo que calcula el promedio de las calidficaciones de varios alumnos
# Utilizando estructuras secuancial, de seleccion y repetitiva (While loop)

print("Bienvenido al sistema de calculo de promedios")
#Estructura secuancial: Ingreso de datos
cantidad_alumnos =int(input("CUantos alumnos deseas evaluar?"))

#Iniciamos Variables
contador = 1
suma_total = 0

# estructura repetitiva: While loop
while contador <= cantidad_alumnos:
    calificacion =float(input("Ingresa la calificacion del alumno (1-10): "))

    # estructura de seleccion 
    if calificacion >= 6:
        print("El alumno ha aprobado")
    else:
        print("El alumno ha reprobado")
    suma_total += calificacion
    contador += 1 # incremento del contador
promedio = suma_total / cantidad_alumnos
print(f"El promedio de las calificaciones es: {promedio:.2f}")

#Estructua de seleccion
if promedio >= 8:
    print("El grupo de alumnos tiene un buen desempeño")
elif promedio >= 6:
    print("El grupo de alumnos tiene un desempeño regular")
else:
    print("El grupo de alumnos tiene un mal desempeño")

    
