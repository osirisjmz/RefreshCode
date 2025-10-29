import webbrowser
import threading
import time
import socket
import platform
import json
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask import jsonify

from db_connection import get_connection

app = Flask(__name__)
app.secret_key = 'clave_super_segura_123'

# =====================================
# FUNCION GLOBAL DE LOGS
# =====================================
def write_log(sitio, accion, detalle, resultado, usuario=None, start_time=None):
    """Escribe logs en SQL Server con tiempo de reacción"""
    try:
        reaction = None
        if start_time:
            reaction = int((time.time() - start_time) * 1000)  # tiempo en ms

        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO Logs (sitio, accion, detalle, resultado, usuario, reaction_ms)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (sitio, accion, detalle, resultado, usuario, reaction))
            conn.commit()
            conn.close()
        else:
            print(" No se pudo conectar a la BD para escribir log.")
    except Exception as e:
        print(f" Error al escribir log ({sitio}):", e)

# =====================================
# REGISTRO DE LOGS VIA AJAX
# =====================================
@app.route('/log_action', methods=['POST'])
def log_action():
    try:
        data = request.get_json()
        sitio = data.get('sitio', '')
        accion = data.get('accion', '')
        detalle = data.get('detalle', '')
        usuario = session.get('nombre', 'Anon')

        start_time = time.time()
        write_log(sitio, accion, detalle, 'OK', usuario=usuario, start_time=start_time)
        return jsonify({'status': 'success'}), 200
    except Exception as e:
        write_log('/log_action', 'EXCEPTION', str(e), 'ERROR')
        return jsonify({'status': 'error', 'message': str(e)}), 500


# =====================================
# RUTA PRINCIPAL (LOGIN PAGE)
# =====================================
@app.route('/')
def index():
    start_time = time.time()
    try:
        write_log('/', 'LOAD', 'Pantalla de login cargada', 'OK', start_time=start_time)
        return render_template('login.html')
    except Exception as e:
        write_log('/', 'LOAD_EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al cargar la pantalla de inicio.", "danger")
        return "Error interno en el servidor."
    
@app.route('/login', methods=['POST'])
def login():
    start_time = time.time()
    try:
        matricula = request.form.get('num_matricula', '').strip()
        password = request.form.get('password', '').strip()

        if not matricula or not password:
            flash("Debes ingresar matrícula y contraseña.", "warning")
            write_log('/login', 'VALIDATION', 'Campos vacíos', 'FAIL', start_time=start_time)
            return redirect(url_for('index'))

        conn = get_connection()
        if not conn:
            flash("Error al conectar con la base de datos.", "danger")
            write_log('/login', 'DB_CONNECT', 'Falló conexión a la base', 'ERROR', start_time=start_time)
            return redirect(url_for('index'))

        cursor = conn.cursor()
        cursor.execute("""
            SELECT usuario_id, nombre, tipo_usuario, password
            FROM Usuario
            WHERE LOWER(num_matricula) = LOWER(?)
        """, (matricula,))
        user = cursor.fetchone()

        direccion_ip = request.remote_addr or socket.gethostbyname(socket.gethostname())
        navegador = request.user_agent.string
        sistema = platform.system()

        # === LOGIN EXITOSO ===
        if user and user[3] == password:
            session['usuario_id'] = user[0]
            session['nombre'] = user[1]
            session['tipo_usuario'] = user[2]

            cursor.execute("""
                INSERT INTO UserLogin (usuario_id, num_matricula, fecha_login, estado_login, direccion_ip, navegador, ip)
                VALUES (?, ?, GETDATE(), ?, ?, ?, ?)
            """, (user[0], matricula, "OK", direccion_ip, navegador, direccion_ip))
            conn.commit()
            conn.close()

            write_log('/login', 'LOGIN', f'Usuario {matricula} inició sesión', 'OK',
                      usuario=matricula, start_time=start_time)
            flash(f"Bienvenido {user[1]}", "success")
            return redirect(url_for('home'))

        # === LOGIN FALLIDO ===
        else:
            cursor.execute("""
                INSERT INTO UserLogin (usuario_id, num_matricula, fecha_login, estado_login, direccion_ip, navegador, ip)
                VALUES (?, ?, GETDATE(), ?, ?, ?, ?)
            """, (None, matricula, "FAIL", direccion_ip, navegador, direccion_ip))
            conn.commit()
            conn.close()

            write_log('/login', 'LOGIN', f'Intento fallido matrícula {matricula}', 'FAIL',
                      usuario=matricula, start_time=start_time)
            flash("Matrícula o contraseña incorrecta.", "danger")
            return redirect(url_for('index'))

    except Exception as e:
        write_log('/login', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error interno en el inicio de sesión.", "danger")
        return redirect(url_for('index'))


# =====================================
# REGISTRO DE USUARIOS
# =====================================
@app.route('/register', methods=['GET', 'POST'])
def register():
    start_time = time.time()
    conn = get_connection()
    if not conn:
        flash("Error al conectar con la base de datos.", "danger")
        write_log('/register', 'DB_CONNECT', 'No se pudo conectar', 'ERROR', start_time=start_time)
        return redirect(url_for('index'))

    cursor = conn.cursor()
    cursor.execute("SELECT carrera_id, nombre_carrera FROM Carrera ORDER BY nombre_carrera ASC")
    carreras = cursor.fetchall()

    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        email = request.form['email']
        num_matricula = request.form['num_matricula']
        carrera_id = request.form['carrera_id']
        password = request.form['password']
        tipo_usuario = "Estudiante"

        try:
            cursor.execute("""
                INSERT INTO Usuario (nombre, apellido, email, num_matricula, carrera, password, tipo_usuario)
                VALUES (?, ?, ?, ?, 
                    (SELECT nombre_carrera FROM Carrera WHERE carrera_id = ?), ?, ?)
            """, (nombre, apellido, email, num_matricula, carrera_id, password, tipo_usuario))
            conn.commit()
            conn.close()

            flash("Registro exitoso. Ya puedes iniciar sesión.", "success")
            write_log('/register', 'INSERT Usuario',
                      f'Usuario registrado: {nombre} {apellido} - {num_matricula}', 'OK',
                      usuario=num_matricula, start_time=start_time)
            return redirect(url_for('index'))

        except Exception as e:
            conn.rollback()
            conn.close()
            flash(f"Error al registrar usuario: {e}", "danger")
            write_log('/register', 'INSERT Usuario', str(e), 'ERROR',
                      usuario=num_matricula, start_time=start_time)

    return render_template('register.html', carreras=carreras)


# =====================================
# HOME PAGE
# =====================================
@app.route('/home')
def home():
    start_time = time.time()
    try:
        if 'usuario_id' not in session:
            write_log('/home', 'ACCESS_DENIED', 'Sesión no iniciada', 'FAIL', start_time=start_time)
            flash("Debes iniciar sesión para acceder al home.", "warning")
            print("⚠️ Sesión no iniciada, redirigiendo a login")
            return redirect(url_for('index'))

        write_log('/home', 'ACCESS', 'Usuario accedió al home', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        print(f"✅ Acceso permitido al home para {session.get('nombre')}")
        return render_template('home.html', nombre=session['nombre'])

    except Exception as e:
        write_log('/home', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        print("💥 Error en /home:", e)
        return redirect(url_for('index'))



# =====================================
# CATALOGO DE LIBROS
# =====================================
@app.route('/catalog/<categoria>')
def catalog(categoria):
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT libro_id, titulo, autores, editorial, anio_publicacion, isbn, num_copias_disponibles, estante
            FROM Libro
            WHERE categoria = ?
        """, (categoria,))
        libros = cursor.fetchall()
        conn.close()

        write_log('/catalog', 'ACCESS', f'Catálogo cargado: {categoria}', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        return render_template('catalog.html', categoria=categoria, libros=libros)
    except Exception as e:
        write_log('/catalog', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        return "Error cargando catálogo", 500
 # =====================================
# PRESTAMO
# =====================================
@app.route('/prestamo/<int:libro_id>')
def prestamo(libro_id):
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Buscar ejemplar disponible
        cursor.execute("""
            SELECT TOP 1 ejemplar_id
            FROM Ejemplar
            WHERE libro_id = ? AND estado = 'nuevo'
        """, (libro_id,))
        ejemplar = cursor.fetchone()

        if not ejemplar:
            flash("No hay ejemplares disponibles para este libro.", "warning")
            write_log('/prestamo', 'NO_STOCK', f'Libro {libro_id} sin ejemplares', 'FAIL',
                      usuario=session.get('nombre'), start_time=start_time)
            return redirect(url_for('home'))

        # Insertar en tabla Prestamo
        cursor.execute("""
            INSERT INTO Prestamo (usuario_id, fecha_prestamo, fecha_vencimiento)
            VALUES (?, GETDATE(), DATEADD(DAY, 7, GETDATE()))
        """, (session.get('usuario_id'),))
        conn.commit()

        # Obtener el ID del préstamo recién insertado
        cursor.execute("SELECT SCOPE_IDENTITY()")
        prestamo_id = int(cursor.fetchone()[0])

        # Insertar en Prestamo_Item
        cursor.execute("""
            INSERT INTO Prestamo_Item (prestamo_id, ejemplar_id, fecha_devolucion_item)
            VALUES (?, ?, NULL)
        """, (prestamo_id, ejemplar[0]))
        conn.commit()

        # Actualizar estado del ejemplar
        cursor.execute("""
            UPDATE Ejemplar SET estado = 'prestado'
            WHERE ejemplar_id = ?
        """, (ejemplar[0],))
        conn.commit()
        conn.close()

        write_log('/prestamo', 'INSERT', f'Préstamo exitoso libro {libro_id}', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        flash("Préstamo realizado exitosamente.", "success")
        return redirect(url_for('home'))

    except Exception as e:
        write_log('/prestamo', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al procesar el préstamo.", "danger")
        return redirect(url_for('home'))


# =====================================
# RESERVA
# =====================================
@app.route('/reserva/<int:libro_id>')
def reserva(libro_id):
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Reserva (usuario_id, libro_id, fecha_reserva, fecha_limite_retiro, estado)
            VALUES (?, ?, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'activa')
        """, (session.get('usuario_id'), libro_id))
        conn.commit()
        conn.close()

        write_log('/reserva', 'INSERT', f'Reserva exitosa libro {libro_id}', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        flash("Reserva registrada correctamente.", "success")
        return redirect(url_for('home'))

    except Exception as e:
        write_log('/reserva', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al registrar la reserva.", "danger")
        return redirect(url_for('home'))
 # =====================================
# MIS PRESTAMOS
# =====================================
@app.route('/prestamos')
def prestamos():
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT pi.prestamo_item_id, l.titulo, p.fecha_prestamo, p.fecha_vencimiento, e.estante
            FROM Prestamo_Item pi
            INNER JOIN Prestamo p ON pi.prestamo_id = p.prestamo_id
            INNER JOIN Ejemplar e ON pi.ejemplar_id = e.ejemplar_id
            INNER JOIN Libro l ON e.libro_id = l.libro_id
            WHERE p.usuario_id = ? AND e.estado = 'prestado'
        """, (session.get('usuario_id'),))
        rows = cursor.fetchall()
        conn.close()

        prestamos = [
            {
                'prestamo_item_id': r[0],
                'titulo': r[1],
                'fecha_prestamo': r[2],
                'fecha_vencimiento': r[3],
                'estante': r[4]
            } for r in rows
        ]

        write_log('/prestamos', 'ACCESS', 'Cargados préstamos del usuario', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        return render_template('prestamos.html', prestamos=prestamos)

    except Exception as e:
        write_log('/prestamos', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al cargar tus préstamos.", "danger")
        return redirect(url_for('home'))


# =====================================
# DEVOLVER LIBRO
# =====================================
@app.route('/devolver/<int:prestamo_item_id>')
def devolver(prestamo_item_id):
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Obtener ejemplar relacionado
        cursor.execute("""
            SELECT ejemplar_id FROM Prestamo_Item WHERE prestamo_item_id = ?
        """, (prestamo_item_id,))
        ejemplar = cursor.fetchone()
        if not ejemplar:
            flash("No se encontró el ejemplar para devolución.", "danger")
            return redirect(url_for('prestamos'))

        # Actualizar devolución y estado
        cursor.execute("""
            UPDATE Prestamo_Item SET fecha_devolucion_item = GETDATE()
            WHERE prestamo_item_id = ?
        """, (prestamo_item_id,))
        cursor.execute("""
            UPDATE Ejemplar SET estado = 'nuevo'
            WHERE ejemplar_id = ?
        """, (ejemplar[0],))
        conn.commit()
        conn.close()

        write_log('/devolver', 'UPDATE', f'Devolución ejemplar {ejemplar[0]}', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        flash("Libro devuelto correctamente.", "success")
        return redirect(url_for('prestamos'))

    except Exception as e:
        write_log('/devolver', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al devolver el libro.", "danger")
        return redirect(url_for('prestamos'))


# =====================================
# MIS RESERVAS
# =====================================
@app.route('/reservas')
def reservas():
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT r.reserva_id, l.titulo, r.fecha_reserva, r.fecha_limite_retiro, r.estado
            FROM Reserva r
            INNER JOIN Libro l ON r.libro_id = l.libro_id
            WHERE r.usuario_id = ? AND r.estado = 'activa'
        """, (session.get('usuario_id'),))
        rows = cursor.fetchall()
        conn.close()

        reservas = [
            {
                'reserva_id': r[0],
                'titulo': r[1],
                'fecha_reserva': r[2],
                'fecha_limite_retiro': r[3],
                'estado': r[4]
            } for r in rows
        ]

        write_log('/reservas', 'ACCESS', 'Cargadas reservas del usuario', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        return render_template('reservas.html', reservas=reservas)

    except Exception as e:
        write_log('/reservas', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al cargar tus reservas.", "danger")
        return redirect(url_for('home'))


# =====================================
# CANCELAR RESERVA
# =====================================
@app.route('/cancelar_reserva/<int:reserva_id>')
def cancelar_reserva(reserva_id):
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE Reserva SET estado = 'cancelada' WHERE reserva_id = ?
        """, (reserva_id,))
        conn.commit()
        conn.close()

        write_log('/cancelar_reserva', 'UPDATE', f'Reserva {reserva_id} cancelada', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        flash("Reserva cancelada correctamente.", "success")
        return redirect(url_for('reservas'))

    except Exception as e:
        write_log('/cancelar_reserva', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al cancelar la reserva.", "danger")
        return redirect(url_for('reservas'))
  
# =====================================
# ABRIR FIREFOX AUTOMÁTICAMENTE
# =====================================
def abrir_firefox():
    time.sleep(2)
    webbrowser.get(r'"C:\Program Files\Mozilla Firefox\firefox.exe" %s').open_new("http://127.0.0.1:5000")

# =====================================
# DASHBOARD ADMINISTRATIVO
# =====================================
@app.route('/admin/dashboard')
def admin_dashboard():
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Total de préstamos, reservas y devoluciones
        cursor.execute("SELECT COUNT(*) FROM Prestamo")
        total_prestamos = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM Reserva WHERE estado = 'activa'")
        total_reservas = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM Prestamo_Item WHERE fecha_devolucion_item IS NOT NULL")
        total_devoluciones = cursor.fetchone()[0]

        # Promedio de tiempos de reacción
        cursor.execute("SELECT AVG(reaction_ms) FROM Logs WHERE reaction_ms IS NOT NULL")
        promedio_reaccion = cursor.fetchone()[0] or 0

        # Top 5 libros más prestados
        cursor.execute("""
            SELECT TOP 5 L.titulo, COUNT(PI.prestamo_item_id) AS total
            FROM Prestamo_Item PI
            INNER JOIN Ejemplar E ON PI.ejemplar_id = E.ejemplar_id
            INNER JOIN Libro L ON E.libro_id = L.libro_id
            GROUP BY L.titulo
            ORDER BY total DESC
        """)
        top_libros = cursor.fetchall()

        # Actividad reciente del sistema (últimos 10 logs)
        cursor.execute("""
            SELECT TOP 10 fecha_hora, sitio, accion, resultado, usuario
            FROM Logs ORDER BY fecha_hora DESC
        """)
        logs_recientes = cursor.fetchall()

        conn.close()

        data = {
            "total_prestamos": total_prestamos,
            "total_reservas": total_reservas,
            "total_devoluciones": total_devoluciones,
            "promedio_reaccion": round(promedio_reaccion, 2),
            "top_libros": top_libros,
            "logs_recientes": logs_recientes
        }

        write_log('/admin/dashboard', 'ACCESS', 'Dashboard cargado exitosamente', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        return render_template('admin_dashboard.html', data=data)

    except Exception as e:
        write_log('/admin/dashboard', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al cargar el panel administrativo.", "danger")
        return redirect(url_for('home'))
# =====================================
# AUDITORÍA DE LOGS (con filtros)
# =====================================
@app.route('/admin/logs', methods=['GET', 'POST'])
def logs_auditoria():
    start_time = time.time()
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # --- Parámetros de filtro ---
        fecha_inicio = request.form.get('fecha_inicio')
        fecha_fin = request.form.get('fecha_fin')
        usuario = request.form.get('usuario')
        accion = request.form.get('accion')

        query = "SELECT fecha_hora, sitio, accion, detalle, resultado, usuario, reaction_ms FROM Logs WHERE 1=1"
        params = []

        if fecha_inicio:
            query += " AND fecha_hora >= ?"
            params.append(fecha_inicio)
        if fecha_fin:
            query += " AND fecha_hora <= ?"
            params.append(fecha_fin)
        if usuario:
            query += " AND usuario LIKE ?"
            params.append(f"%{usuario}%")
        if accion:
            query += " AND accion LIKE ?"
            params.append(f"%{accion}%")

        query += " ORDER BY fecha_hora DESC"
        cursor.execute(query, params)
        logs = cursor.fetchall()
        conn.close()

        write_log('/admin/logs', 'ACCESS', 'Vista de auditoría cargada', 'OK',
                  usuario=session.get('nombre'), start_time=start_time)
        return render_template('logs_auditoria.html', logs=logs)

    except Exception as e:
        write_log('/admin/logs', 'EXCEPTION', str(e), 'ERROR', start_time=start_time)
        flash("Error al cargar la auditoría.", "danger")
        return redirect(url_for('admin_dashboard'))

# =====================================
# MAIN
# =====================================
if __name__ == '__main__':
    threading.Thread(target=abrir_firefox).start()
    app.run(debug=True)
