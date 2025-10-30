# Docker provee instrucciones dedicadas para cada sistema operativo.
# Por favor consulta la documentación oficial en https://www.docker.com/get-started/

# Descarga la imagen de Docker de Node.js:
docker pull node:22-alpine

# Crea un contenedor de Node.js e inicia una sesión shell:
docker run -it --rm --entrypoint sh node:22-alpine

# Verify the Node.js version:
node -v # Should print "v22.20.0".

# Verifica versión de npm:
npm -v # Debería mostrar "10.9.3".
