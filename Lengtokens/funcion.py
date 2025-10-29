import tiktoken

def contar_tokens(texto, modelo="gpt-4o-mini"):
    """
    Cuenta el número de tokens que se usarían en un modelo de OpenAI.
    Args:
        texto (str): Texto de entrada.
        modelo (str): Modelo de referencia (por defecto gpt-4o-mini).
    Returns:
        tuple: (lista_de_tokens, cantidad_total)
    """
    # Carga el codificador según el modelo
    encoding = tiktoken.encoding_for_model(modelo)
    
    # Tokeniza el texto
    tokens = encoding.encode(texto)
    
    # Devuelve la lista y la cantidad
    return tokens, len(tokens)

# Ejemplo de uso
if __name__ == "__main__":
    texto = "si pedro tiene 25 años y su hermano 5 años, ¿cuantos años tiene pedro?"
    tokens, cantidad = contar_tokens(texto)
    print(f"Tokens: {tokens}")
    print(f"Cantidad total: {cantidad}")
# requirements --- IGNORE ---