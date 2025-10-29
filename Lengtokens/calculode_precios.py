import tiktoken

def contar_tokens(texto, modelo="gpt-4o-mini"):
    """
    Cuenta el número de tokens que se usarían en un modelo de OpenAI.
    Args:
        texto (str): Texto de entrada.
        modelo (str): Modelo de referencia.
    Returns:
        tuple: (lista_de_tokens, cantidad_total)
    """
    try:
        encoding = tiktoken.encoding_for_model(modelo)
    except KeyError:
        # Si el modelo no es reconocido, usa un codificador base
        encoding = tiktoken.get_encoding("cl100k_base")

    tokens = encoding.encode(texto)
    return tokens, len(tokens)

def estimar_costo(tokens, tipo="gpt-5-mini", entrada=True):
    precios = {
        "gpt-5-pro": {"in": 15.00, "out": 120.00},
        "gpt-5": {"in": 1.25, "out": 10.00},
        "gpt-5-mini": {"in": 0.25, "out": 2.00},
        "gpt-5-nano": {"in": 0.05, "out": 0.40},
    }
    millones = len(tokens) / 1_000_000
    precio = precios[tipo]["in" if entrada else "out"]
    return millones * precio

if __name__ == "__main__":
    texto = input("Escribe el texto que deseas analizar:\n> ")
    modelo = input("Modelo (gpt-5, gpt-5-mini, gpt-5-pro, gpt-5-nano): ") or "gpt-5-mini"

    tokens, cantidad = contar_tokens(texto)
    costo = estimar_costo(tokens, tipo=modelo)

    print("\n--- RESULTADO ---")
    print(f"Tokens generados: {cantidad}")
    print(f"Costo estimado de entrada: ${costo:.8f} USD")
