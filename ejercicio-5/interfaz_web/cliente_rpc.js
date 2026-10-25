/**
 * ==========================================================================
 *  ARCHIVO: interfaz_web/cliente_rpc.js
 *  DESCRIPCIÓN: Lógica del lado del cliente (Frontend).
 *               Maneja el estado de la sesión, la manipulación del DOM y 
 *               la comunicación asíncrona (AJAX/Fetch) con el servidor RPC.
 * ==========================================================================
 */

document.addEventListener('DOMContentLoaded', () => {
    
    // ====================================================================
    //   1. REFERENCIAS AL DOM (Evitamos buscar en el DOM repetidas veces)
    // ====================================================================
    
    // Vistas principales.
    const vistaAcceso = document.getElementById('vista-acceso');
    const vistaInventario = document.getElementById('vista-inventario');
    
    // Formularios de Seguridad.
    const formLogin = document.getElementById('form-login');
    const formRegistro = document.getElementById('form-registro');
    const linkRegistro = document.getElementById('link-registro');
    const linkLogin = document.getElementById('link-login');
    
    // Elementos de Sesión.
    const labelUsuario = document.getElementById('label-usuario');
    const btnCerrarSesion = document.getElementById('btn-cerrar-sesion');
    
    // Formulario de Productos (Alta/Edición).
    const formProducto = document.getElementById('form-producto');
    const inputModo = document.getElementById('prod-modo');
    const inputId = document.getElementById('prod-id');
    const inputNombre = document.getElementById('prod-nombre');
    const inputPrecio = document.getElementById('prod-precio');
    const tituloFormProducto = document.getElementById('titulo-form-producto');
    const btnCancelarEdicion = document.getElementById('btn-cancelar-edicion');
    
    // Grilla y Reportes.
    const tablaProductosBody = document.getElementById('tabla-productos-body');
    const btnGenerarReporte = document.getElementById('btn-generar-reporte');
    const linkVerReporte = document.getElementById('link-ver-reporte');
    const toastContainer = document.getElementById('toast-container');

    // ===============================
    //  2. NÚCLEO DE COMUNICACIÓN RPC
    // ===============================
    
    /**
     * Envía una petición POST al endpoint /rpc.
     * Empaqueta el nombre del procedimiento, credenciales y argumentos en formato TSV.
     * @param {string} procedimiento - Nombre de la función en la API Bash.
     * @param {Array} argumentos - Array de parámetros a enviar.
     * @returns {Object} { exito: boolean, datos: Array de líneas }
     */
    async function llamadaRPC(procedimiento, argumentos = []) {
        // Recuperamos el estado de sesión actual.
        const uid = sessionStorage.getItem('uid') || '';
        const uname = sessionStorage.getItem('uname') || '';
        
        // Construimos el payload TSV: accion \t uid \t uname \t arg1 \t arg2...
        const payload = [procedimiento, uid, uname, ...argumentos].join('\t');
        
        try {
            const respuesta = await fetch('/rpc', {
                method: 'POST',
                body: payload
            });
            
            if (!respuesta.ok) throw new Error("Fallo de red al contactar al servidor.");
            
            const textoOriginal = await respuesta.text();
            
            // Separamos por salto de línea y limpiamos líneas vacías.
            const lineas = textoOriginal.split('\n').map(l => l.trim()).filter(l => l !== '');
            
            if (lineas.length === 0) throw new Error("El servidor devolvió una respuesta vacía.");
            
            // La primera línea define el estado (OK o ERROR devuelto por el Gateway de Bash).
            const estado = lineas.shift(); 
            
            return {
                exito: estado === 'OK',
                datos: lineas
            };
            
        } catch (error) {
            mostrarToast("Error de conexión: " + error.message, "error");
            return { exito: false, datos: [error.message] };
        }
    }

    // ===========================
    //  3. UTILIDADES DE INTERFAZ
    // ===========================
    
    function mostrarToast(mensaje, tipo = 'exito') {
        const toast = document.createElement('div');
        toast.className = `toast ${tipo}`;
        toast.textContent = mensaje;
        toastContainer.appendChild(toast);
        
        // El CSS se encarga de la animación. Lo removemos del DOM tras 3 segundos.
        setTimeout(() => {
            if(toastContainer.contains(toast)) toast.remove();
        }, 3000);
    }

    function alternarVistas(mostrarInventario) {
        if (mostrarInventario) {
            vistaAcceso.classList.remove('activa');
            vistaInventario.classList.add('activa');
            vistaInventario.classList.remove('oculta');
        } else {
            vistaInventario.classList.remove('activa');
            vistaInventario.classList.add('oculta');
            vistaAcceso.classList.add('activa');
        }
    }

    // ================================================================
    //  4. CONTROLADORES DE SESIÓN (STATELESS -> STATEFUL CLIENT-SIDE)
    // ================================================================
    
    function verificarSesion() {
        const uname = sessionStorage.getItem('uname');
        if (uname) {
            labelUsuario.textContent = `Hola, ${uname}`;
            alternarVistas(true);
            cargarProductos(); // Cargamos la grilla automáticamente al entrar.
        } else {
            alternarVistas(false);
        }
    }

    btnCerrarSesion.addEventListener('click', () => {
        sessionStorage.clear(); // Limpiamos la memoria del cliente.
        formLogin.reset();
        verificarSesion();
        mostrarToast("Sesión cerrada.", "exito");
    });

    // Alternar entre login y registro visualmente.
    linkRegistro.addEventListener('click', (e) => {
        e.preventDefault();
        formLogin.classList.remove('activa');
        formLogin.classList.add('oculta');
        formRegistro.classList.remove('oculta');
        formRegistro.classList.add('activa');
    });

    linkLogin.addEventListener('click', (e) => {
        e.preventDefault();
        formRegistro.classList.remove('activa');
        formRegistro.classList.add('oculta');
        formLogin.classList.remove('oculta');
        formLogin.classList.add('activa');
    });

    // Login
    formLogin.addEventListener('submit', async (e) => {
        e.preventDefault();
        const user = document.getElementById('login-user').value;
        const pass = document.getElementById('login-pass').value;
        
        const res = await llamadaRPC('iniciar_sesion', [user, pass]);
        
        if (res.exito) {
            // api_usuarios.sh devuelve: ID \t Usuario \t Mensaje
            const partes = res.datos[0].split('\t');
            sessionStorage.setItem('uid', partes[0]);
            sessionStorage.setItem('uname', partes[1]);
            
            mostrarToast(partes[2], "exito");
            verificarSesion();
        } else {
            mostrarToast(res.datos[0], "error");
        }
    });

    // Registro.
    formRegistro.addEventListener('submit', async (e) => {
        e.preventDefault();
        const user = document.getElementById('reg-user').value;
        const pass = document.getElementById('reg-pass').value;
        
        const res = await llamadaRPC('registrar_usuario', [user, pass]);
        
        if (res.exito) {
            mostrarToast(res.datos[0], "exito");
            linkLogin.click(); // Volvemos al form de login
            formRegistro.reset();
        } else {
            mostrarToast(res.datos[0], "error");
        }
    });

    // ======================================
    //  5. CONTROLADORES DE INVENTARIO (ABM)
    // ======================================
    
    async function cargarProductos() {
        tablaProductosBody.innerHTML = '<tr><td colspan="4" style="text-align:center;">Cargando...</td></tr>';
        
        const res = await llamadaRPC('listar_productos');
        
        if (!res.exito) {
            mostrarToast("Error al cargar productos", "error");
            tablaProductosBody.innerHTML = '<tr><td colspan="4" style="text-align:center; color: red;">Fallo de conexión</td></tr>';
            return;
        }

        tablaProductosBody.innerHTML = '';
        
        if (res.datos.length === 0) {
            tablaProductosBody.innerHTML = '<tr><td colspan="4" style="text-align:center;">No hay productos registrados.</td></tr>';
            return;
        }

        // Iteramos sobre las líneas devueltas por Bash (formato TSV: ID \t Nombre \t Precio).
        res.datos.forEach(linea => {
            const [id, nombre, precio] = linea.split('\t');
            
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${id}</td>
                <td>${nombre}</td>
                <td>$${precio}</td>
                <td class="acciones-celda">
                    <button class="btn btn-info btn-chico btn-editar" data-id="${id}" data-nombre="${nombre}" data-precio="${precio}">✏️</button>
                    <button class="btn btn-peligro btn-chico btn-eliminar" data-id="${id}">🗑️</button>
                </td>
            `;
            tablaProductosBody.appendChild(tr);
        });

        asignarEventosBotonesGrilla();
    }

    // Manejo unificado del formulario Alta/Edición.
    formProducto.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const id = inputId.value;
        const nombre = inputNombre.value;
        const precio = inputPrecio.value;
        const modo = inputModo.value; // 'alta' o 'edicion'
        
        const accion = (modo === 'alta') ? 'alta_producto' : 'editar_producto';
        
        const res = await llamadaRPC(accion, [id, nombre, precio]);
        
        if (res.exito) {
            mostrarToast(res.datos[0], "exito");
            resetFormularioProducto();
            cargarProductos();
        } else {
            mostrarToast(res.datos[0], "error");
        }
    });

    // Restaurar formulario a modo "Alta".
    function resetFormularioProducto() {
        formProducto.reset();
        inputModo.value = 'alta';
        inputId.disabled = false; // Permitimos editar el ID de nuevo.
        tituloFormProducto.textContent = 'Alta de Producto';
        btnCancelarEdicion.classList.add('oculta');
    }

    btnCancelarEdicion.addEventListener('click', resetFormularioProducto);

    // Asignar eventos a los botones dinámicos de la grilla.
    function asignarEventosBotonesGrilla() {
        // Eliminar
        document.querySelectorAll('.btn-eliminar').forEach(btn => {
            btn.addEventListener('click', async (e) => {
                const id = e.target.getAttribute('data-id');
                if (confirm(`¿Seguro que deseás eliminar el producto ID ${id}?`)) {
                    const res = await llamadaRPC('baja_producto', [id]);
                    if (res.exito) {
                        mostrarToast(res.datos[0], "exito");
                        cargarProductos();
                    } else {
                        mostrarToast(res.datos[0], "error");
                    }
                }
            });
        });

        // Editar (Carga los datos en el formulario lateral).
        document.querySelectorAll('.btn-editar').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const id = e.target.getAttribute('data-id');
                const nombre = e.target.getAttribute('data-nombre');
                const precio = e.target.getAttribute('data-precio');
                
                inputModo.value = 'edicion';
                inputId.value = id;
                inputId.disabled = true; // Por reglas de BD relacional, la PK no se edita.
                inputNombre.value = nombre;
                inputPrecio.value = precio;
                
                tituloFormProducto.textContent = `Editando ID: ${id}`;
                btnCancelarEdicion.classList.remove('oculta');
            });
        });
    }

    // ===========================
    //  6. GENERACIÓN DE REPORTES
    // ===========================
    
    btnGenerarReporte.addEventListener('click', async () => {
        // Mostramos indicador de carga visual.
        const textoOriginal = btnGenerarReporte.textContent;
        btnGenerarReporte.textContent = "Generando...";
        btnGenerarReporte.disabled = true;
        
        const res = await llamadaRPC('generar_reporte');
        
        if (res.exito) {
            mostrarToast(res.datos[0], "exito");
            linkVerReporte.classList.remove('oculta'); // Habilitamos el botón para ver HTML.
        } else {
            mostrarToast(res.datos[0], "error");
        }
        
        btnGenerarReporte.textContent = textoOriginal;
        btnGenerarReporte.disabled = false;
    });

    // =======================
    //  7. ARRANQUE DE LA APP
    // =======================
    verificarSesion(); // Disparamos la lógica al cargar el DOM.
});