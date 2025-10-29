import tiktoken
import os
from datetime import datetime

# === CONFIGURACIÓN INICIAL ===
CARPETA_LOGS = os.path.join(os.path.dirname(__file__), "logs")
os.makedirs(CARPETA_LOGS, exist_ok=True)

ARCHIVO_LOG = os.path.join(CARPETA_LOGS, "token_log.txt")
ARCHIVO_SALDO = os.path.join(CARPETA_LOGS, "saldo_tokens.txt")
ARCHIVO_SALDO_ACTUAL = os.path.join(CARPETA_LOGS, "saldo_actual.txt")

TOKENS_INICIALES = 1_000_000  # saldo inicial


def contar_tokens(texto, modelo="gpt-4o-mini"):
    """Cuenta los tokens del texto para el modelo indicado."""
    try:
        encoding = tiktoken.encoding_for_model(modelo)
    except KeyError:
        encoding = tiktoken.get_encoding("cl100k_base")
    tokens = encoding.encode(texto)
    return tokens, len(tokens)


def estimar_costo(tokens, tipo="gpt-5-mini", entrada=True):
    """Calcula el costo estimado basado en el número de tokens."""
    precios = {
        "gpt-5-pro": {"in": 15.00, "out": 120.00},
        "gpt-5": {"in": 1.25, "out": 10.00},
        "gpt-5-mini": {"in": 0.25, "out": 2.00},
        "gpt-5-nano": {"in": 0.05, "out": 0.40},
    }

    tipo = tipo.strip().lower()
    if tipo not in precios:
        print(f"⚠️ Modelo '{tipo}' no reconocido, se usará gpt-5-mini.")
        tipo = "gpt-5-mini"

    millones = len(tokens) / 1_000_000
    precio = precios[tipo]["in" if entrada else "out"]
    return millones * precio


def leer_saldo():
    """Lee el saldo restante desde el archivo saldo_actual.txt."""
    if not os.path.exists(ARCHIVO_SALDO_ACTUAL):
        # Crear el archivo si no existe
        with open(ARCHIVO_SALDO_ACTUAL, "w", encoding="utf-8") as f:
            f.write(f"{TOKENS_INICIALES},{0.0}")
        return TOKENS_INICIALES, 0.0

    with open(ARCHIVO_SALDO_ACTUAL, "r", encoding="utf-8") as f:
        contenido = f.read().strip()

    try:
        tokens_restantes, costo_acumulado = map(float, contenido.split(","))
        return int(tokens_restantes), costo_acumulado
    except ValueError:
        # Si el archivo se corrompe, reinicia los valores
        print("⚠️ Archivo de saldo dañado. Reiniciando valores base.")
        return TOKENS_INICIALES, 0.0


def guardar_saldo(tokens_restantes, costo_acumulado, cantidad_tokens, costo_actual):
    """Guarda el nuevo saldo actualizado en formato legible, con fecha."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    separador = "=" * 80
    nuevo_registro = (
        f"{separador}\n"
        f"[{timestamp}]\n"
        f"Tokens usados: {cantidad_tokens:,} | Tokens restantes: {tokens_restantes:,}\n"
        f"Costo actual: ${costo_actual:.8f} | Acumulado: ${costo_acumulado:.8f}\n"
        f"{separador}\n"
    )

    # Insertar al inicio del historial
    contenido_anterior = ""
    if os.path.exists(ARCHIVO_SALDO):
        with open(ARCHIVO_SALDO, "r", encoding="utf-8") as f:
            contenido_anterior = f.read()

    with open(ARCHIVO_SALDO, "w", encoding="utf-8") as f:
        f.write(nuevo_registro + contenido_anterior)

    # Actualizar saldo actual en formato máquina
    with open(ARCHIVO_SALDO_ACTUAL, "w", encoding="utf-8") as f:
        f.write(f"{tokens_restantes},{costo_acumulado}")


def registrar_en_log(texto, modelo, cantidad_tokens, costo):
    """Registra la operación en el archivo log con el texto completo."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    separador = "=" * 80
    registro = (
        f"\n{separador}\n"
        f"[{timestamp}]\n"
        f"Modelo: {modelo}\n"
        f"Tokens: {cantidad_tokens}\n"
        f"Costo: ${costo:.8f}\n"
        f"Texto completo:\n{texto}\n"
        f"{separador}\n"
    )
    with open(ARCHIVO_LOG, "a", encoding="utf-8") as f:
        f.write(registro)


if __name__ == "__main__":
    tokens_restantes, costo_acumulado = leer_saldo()

    print(f"📊 Tokens disponibles: {tokens_restantes:,}")
    print(f"💰 Costo acumulado: ${costo_acumulado:.6f}\n")

    texto = input("Escribe el texto que deseas analizar:\n> ")
    modelo = input("Modelo (gpt-5, gpt-5-mini, gpt-5-pro, gpt-5-nano): ") or "gpt-5-mini"

    tokens, cantidad = contar_tokens(texto)
    costo = estimar_costo(tokens, tipo=modelo)

    # Actualizar saldo
    tokens_restantes -= cantidad
    costo_acumulado += costo

    guardar_saldo(tokens_restantes, costo_acumulado, cantidad, costo)
    registrar_en_log(texto, modelo, cantidad, costo)

    print("\n--- RESULTADO ---")
    print(f"Tokens generados: {cantidad}")
    print(f"Costo estimado: ${costo:.8f} USD")
    print(f"Tokens restantes: {tokens_restantes:,}")
    print(f"Costo total acumulado: ${costo_acumulado:.8f}")
    print("\n🪶 Registro guardado y saldo actualizado correctamente.")
