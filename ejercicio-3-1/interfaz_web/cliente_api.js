/**
 * ==============================================================================
 *  ARCHIVO: interfaz_web/cliente_api.js
 *  DESCRIPCIÓN: Capa de abstracción del cliente (Vanilla JS).
 *  Se encarga de gestionar el estado de la sesión en el navegador y estructurar 
 *  las peticiones asíncronas (AJAX) hacia el enrutador CGI del backend.
 * ==============================================================================
 */

const ClienteAPI = {
    // Ruta relativa hacia el enlace simbólico que creamos en iniciar_servidor.sh.
    ENDPOINT: "../cgi-bin/enrutador_cgi.sh",

    /**
     * Motor principal de peticiones. Intercepta todas las llamadas para inyectar automáticamente 
     * los datos de sesión (stateless backend).
     * @param {string} accion - El caso del switch a ejecutar en el backend.
     * @param {object} payload - Los datos específicos del formulario.
     */
    async enviarPeticion(accion, payload = {}) {
        // Recuperamos la sesión actual del almacenamiento del navegador
        const userId = sessionStorage.getItem("user_id") || "";
        const userName = sessionStorage.getItem("user_name") || "";

        // Construimos el paquete JSON final inyectando el contexto.
        const cuerpoPeticion = {
            accion: accion,
            user_id: userId,
            user_name: userName,
            ...payload
        };

        try {
            const respuesta = await fetch(this.ENDPOINT, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(cuerpoPeticion)
            });

            if (!respuesta.ok) {
                throw new Error(`Error HTTP: ${respuesta.status}`);
            }

            // El backend devuelve siempre un JSON (status, message, data, etc.).
            const datos = await respuesta.json();
            return datos;

        } catch (error) {
            console.error("[ClienteAPI] Fallo de red o parseo:", error);
            return { status: "error", message: "Fallo de comunicación con el servidor local." };
        }
    },

    // ============================
    //  SERVICIOS DE AUTENTICACIÓN
    // ============================

    async iniciarSesion(username, password) {
        const respuesta = await this.enviarPeticion("iniciar_sesion", { username, password });
        
        // Si el login es exitoso, persistimos la sesión en el navegador.
        if (respuesta.status === "success") {
            sessionStorage.setItem("user_id", respuesta.user_id);
            sessionStorage.setItem("user_name", respuesta.user_name);
        }
        return respuesta;
    },

    async registrarUsuario(username, password) {
        return await this.enviarPeticion("registrar_usuario", { username, password });
    },

    cerrarSesion() {
        sessionStorage.clear();
        window.location.href = "index.html"; // Redirige a la pantalla de login.
    },

    // ====================================
    //  SERVICIOS DE GESTIÓN DE INVENTARIO
    // ====================================

    async listarProductos() {
        return await this.enviarPeticion("listar_productos");
    },

    async altaProducto(id, nombre, precio) {
        return await this.enviarPeticion("alta_producto", { id, nombre, precio });
    },

    async bajaProducto(id) {
        return await this.enviarPeticion("baja_producto", { id });
    },

    async editarProducto(id, nombre, precio) {
        return await this.enviarPeticion("editar_producto", { id, nombre, precio });
    },

    async generarReporte() {
        return await this.enviarPeticion("generar_reporte");
    }
};

// Validamos si hay sesión activa al cargar páginas protegidas.
function requerirAutenticacion() {
    if (!sessionStorage.getItem("user_id") && !window.location.pathname.endsWith("index.html")) {
        alert("Acceso denegado. Debés iniciar sesión.");
        window.location.href = "index.html";
    }
}