from core.logger import log_event
from services.json_service import load_vacantes
from services.excel_service import load_excel
from core.validator import validar_vacante

def main():
    vacantes = load_vacantes()
    for v in vacantes:
        ok, errores = validar_vacante(v)
        if ok:
            log_event("VALIDADO", "Vacante", "Sistema", v["ID_VACANTE"], "Estructura correcta", "OK")
        else:
            log_event("ERROR", "Validación", "Sistema", v["ID_VACANTE"], str(errores), "Fallido")

if __name__ == "__main__":
    main()
