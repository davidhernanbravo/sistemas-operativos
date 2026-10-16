-- =====================================================================
--  ARCHIVO: base_de_datos/esquema.sql
--  DESCRIPCIÓN: Definición estructural de la base de datos relacional.
-- =====================================================================

-- Envolvemos la creación en una transacción para garantizar atomicidad.
BEGIN TRANSACTION; 

-- Tabla de usuarios con almacenamiento de hash.
CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    hash TEXT NOT NULL
);

-- Tabla de productos del inventario.
CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio REAL NOT NULL
);

COMMIT;