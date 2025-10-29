from flask import Flask, render_template, render_template_string, request

app = Flask(__name__)

# HTML para el menú principal
html_template = """
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Menú Escolar</title>
  <style>
    nav { background: #333; padding: 0; margin: 0; }
    nav ul { list-style: none; display: flex; margin: 0; padding: 0; }
    nav ul li { position: relative; }
    nav ul li a { display: block; padding: 14px 20px; color: white; text-decoration: none; }
    nav ul li a:hover { background: #444; }
    nav ul li ul { display: none; position: absolute; background: #444; list-style: none; margin: 0; padding: 0; top: 100%; left: 0; }
    nav ul li:hover ul { display: block; }
    nav ul li ul li a { padding: 12px 16px; }
    nav ul li ul li a:hover { background: #555; }
  </style>
</head>
<body>
  <nav>
    <ul>
      {% for menu in menus %}
      <li><a href="#">{{ menu }}</a>
        <ul>
          <li><a href="/{{ menu|lower }}/alta">Alta</a></li>
          <li><a href="/{{ menu|lower }}/baja">Baja</a></li>
          <li><a href="/{{ menu|lower }}/modificar">Modificar</a></li>
        </ul>
      </li>
      {% endfor %}
    </ul>
  </nav>
</body>
</html>
"""

# Menú principal
@app.route("/")
def index():
    menus = ["Maestros", "Alumnos", "Materias", "Cursos", "Calificaciones"]
    return render_template_string(html_template, menus=menus)

# --- Rutas para los formularios ---
@app.route("/<menu>/alta", methods=["GET", "POST"])
def alta(menu):
    menu = menu.capitalize()
    if request.method == "POST":
        datos = request.form.to_dict()
        return f"<h2>{menu} dado de alta con éxito:</h2><pre>{datos}</pre>"
    return render_template("alta.html", menu=menu)

@app.route("/<menu>/baja", methods=["GET", "POST"])
def baja(menu):
    menu = menu.capitalize()
    if request.method == "POST":
        datos = request.form.to_dict()
        return f"<h2>{menu} dado de baja con éxito:</h2><pre>{datos}</pre>"
    return render_template("baja.html", menu=menu)

@app.route("/<menu>/modificar", methods=["GET", "POST"])
def modificar(menu):
    menu = menu.capitalize()
    if request.method == "POST":
        datos = request.form.to_dict()
        return f"<h2>{menu} modificado con éxito:</h2><pre>{datos}</pre>"
    return render_template("modificar.html", menu=menu)

if __name__ == "__main__":
    app.run(debug=True)
