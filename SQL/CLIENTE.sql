SET SERVEROUTPUT ON;

-- Verifica que no exista la tabla
DECLARE
    tabla VARCHAR2(31) := 'TBL_CLIENTE CASCADE CONSTRAINTS';
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ' || tabla;
  DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' NO EXISTE');
END;
/

CREATE TABLE TBL_CLIENTE (
ID_CLIENTE NUMBER NOT NULL PRIMARY KEY,
CEDULA NUMBER NOT NULL,
NOMBRE VARCHAR(20) NOT NULL,
APELLIDO VARCHAR(30) NOT NULL,
TELEFONO NUMBER NOT NULL,
FECHAINGRESO DATE NOT NULL,
DIRECCION VARCHAR(50)
);

CREATE OR REPLACE PACKAGE pkg_cliente AS
    -- Declaración de procedimientos
    PROCEDURE sp_insertar_cliente(
        p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE,
        p_cedula TBL_CLIENTE.CEDULA%TYPE,
        p_nombre TBL_CLIENTE.NOMBRE%TYPE,
        p_apellido TBL_CLIENTE.APELLIDO%TYPE,
        p_telefono TBL_CLIENTE.TELEFONO%TYPE,
        p_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE,
        p_direccion TBL_CLIENTE.DIRECCION%TYPE
    );

    PROCEDURE sp_leer_cliente(
        p_id_cliente NUMBER
    );

    PROCEDURE sp_actualizar_cliente(
        p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE,
        p_cedula TBL_CLIENTE.CEDULA%TYPE,
        p_nombre TBL_CLIENTE.NOMBRE%TYPE,
        p_apellido TBL_CLIENTE.APELLIDO%TYPE,
        p_telefono TBL_CLIENTE.TELEFONO%TYPE,
        p_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE,
        p_direccion TBL_CLIENTE.DIRECCION%TYPE
    );

    PROCEDURE sp_eliminar_cliente(
        p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE
    );

    PROCEDURE sp_listar_clientes;

    PROCEDURE sp_buscar_clientes_por_rango_fecha(
        p_fecha_inicio TBL_CLIENTE.FECHAINGRESO%TYPE,
        p_fecha_fin TBL_CLIENTE.FECHAINGRESO%TYPE
    );
END pkg_cliente;
/

CREATE OR REPLACE PACKAGE BODY pkg_cliente AS
    PROCEDURE sp_insertar_cliente(
        p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE,
        p_cedula TBL_CLIENTE.CEDULA%TYPE,
        p_nombre TBL_CLIENTE.NOMBRE%TYPE,
        p_apellido TBL_CLIENTE.APELLIDO%TYPE,
        p_telefono TBL_CLIENTE.TELEFONO%TYPE,
        p_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE,
        p_direccion TBL_CLIENTE.DIRECCION%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_CLIENTE
        WHERE ID_CLIENTE = p_id_cliente;

        IF v_count > 0 THEN
            dbms_output.put_line('YA EXISTE UN REGISTRO CON EL ID ' || p_id_cliente);
        ELSE
            INSERT INTO TBL_CLIENTE(ID_CLIENTE, CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION)
            VALUES (p_id_cliente, p_cedula, p_nombre, p_apellido, p_telefono, p_fechaingreso, p_direccion);
            COMMIT;
            dbms_output.put_line('REGISTRO REALIZADO');
        END IF;
    END sp_insertar_cliente;

    PROCEDURE sp_leer_cliente(
        p_id_cliente NUMBER
    ) AS
        v_cedula TBL_CLIENTE.CEDULA%TYPE;
        v_nombre TBL_CLIENTE.NOMBRE%TYPE;
        v_apellido TBL_CLIENTE.APELLIDO%TYPE;
        v_telefono TBL_CLIENTE.TELEFONO%TYPE;
        v_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE;
        v_direccion TBL_CLIENTE.DIRECCION%TYPE;
    BEGIN    
        SELECT CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION
        INTO v_cedula, v_nombre, v_apellido, v_telefono, v_fechaingreso, v_direccion
        FROM TBL_CLIENTE
        WHERE ID_CLIENTE = p_id_cliente;
        
        dbms_output.put_line('CEDULA: ' || v_cedula || ', NOMBRE: ' || v_nombre || ', APELLIDO: ' || v_apellido || ', TELEFONO: ' || v_telefono || ', FECHAINGRESO: ' || v_fechaingreso || ', DIRECCION: ' || v_direccion);
        
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' NO FUE ENCONTRADO.');
    END sp_leer_cliente;

    PROCEDURE sp_actualizar_cliente(
        p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE,
        p_cedula TBL_CLIENTE.CEDULA%TYPE,
        p_nombre TBL_CLIENTE.NOMBRE%TYPE,
        p_apellido TBL_CLIENTE.APELLIDO%TYPE,
        p_telefono TBL_CLIENTE.TELEFONO%TYPE,
        p_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE,
        p_direccion TBL_CLIENTE.DIRECCION%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_CLIENTE
        WHERE ID_CLIENTE = p_id_cliente;

        IF v_count > 0 THEN
            UPDATE TBL_CLIENTE
            SET CEDULA = p_cedula, NOMBRE = p_nombre, APELLIDO = p_apellido, TELEFONO = p_telefono, FECHAINGRESO = p_fechaingreso, DIRECCION = p_direccion
            WHERE ID_CLIENTE = p_id_cliente;
            COMMIT;
            dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' HA SIDO ACTUALIZADO.');
        ELSE 
            dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' NO FUE ENCONTRADO.');
        END IF;
    END sp_actualizar_cliente;

    PROCEDURE sp_eliminar_cliente(
        p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_CLIENTE
        WHERE ID_CLIENTE = p_id_cliente;

        IF v_count > 0 THEN
            DELETE FROM TBL_CLIENTE
            WHERE ID_CLIENTE = p_id_cliente;
            COMMIT;
            dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' FUE ELIMINADO CORRECTAMENTE.');
        ELSE
            dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' NO FUE ENCONTRADO.');
        END IF;
    END sp_eliminar_cliente;

    PROCEDURE sp_listar_clientes AS
    BEGIN
        FOR cliente IN (SELECT ID_CLIENTE, CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION FROM TBL_CLIENTE) LOOP
            dbms_output.put_line('ID: ' || cliente.ID_CLIENTE || ', CEDULA: ' || cliente.CEDULA || ', NOMBRE: ' || cliente.NOMBRE || ', APELLIDO: ' || cliente.APELLIDO || ', TELEFONO: ' || cliente.TELEFONO || ', FECHA INGRESO: ' || cliente.FECHAINGRESO || ', DIRECCION: ' || cliente.DIRECCION);
        END LOOP;
    END sp_listar_clientes;

    PROCEDURE sp_buscar_clientes_por_rango_fecha(
        p_fecha_inicio TBL_CLIENTE.FECHAINGRESO%TYPE,
        p_fecha_fin TBL_CLIENTE.FECHAINGRESO%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_CLIENTE
        WHERE FECHAINGRESO BETWEEN p_fecha_inicio AND p_fecha_fin;

        IF v_count = 0 THEN
            dbms_output.put_line('NO SE ENCONTRARON CLIENTES EN EL RANGO DE FECHAS ESPECIFICADO.');
        ELSE
            FOR cliente IN (SELECT ID_CLIENTE, CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION
                            FROM TBL_CLIENTE
                            WHERE FECHAINGRESO BETWEEN p_fecha_inicio AND p_fecha_fin) LOOP
                dbms_output.put_line('ID: ' || cliente.ID_CLIENTE || ', CEDULA: ' || cliente.CEDULA || ', NOMBRE: ' || cliente.NOMBRE || ', APELLIDO: ' || cliente.APELLIDO || ', TELEFONO: ' || cliente.TELEFONO || ', FECHA INGRESO: ' || cliente.FECHAINGRESO || ', DIRECCION: ' || cliente.DIRECCION);
            END LOOP;
        END IF;
    END sp_buscar_clientes_por_rango_fecha;
END pkg_cliente;
/

CREATE OR REPLACE PACKAGE pkg_cliente_utilidades AS
    -- Declaración de cursores y funciones
    PROCEDURE listar_clientes_por_letra(p_letra CHAR);
    PROCEDURE listar_clientes_mes_actual;
    FUNCTION consultar_cliente_con_cedula(p_cedula NUMBER) RETURN VARCHAR2;
    FUNCTION consultar_cliente_por_nombre(p_nombre VARCHAR2) RETURN VARCHAR2;
END pkg_cliente_utilidades;
/

CREATE OR REPLACE PACKAGE BODY pkg_cliente_utilidades AS
    -- Cursor para buscar clientes que empiezan con una letra específica
    PROCEDURE listar_clientes_por_letra(p_letra CHAR) AS
        CURSOR c_clientes IS
            SELECT ID_CLIENTE, NOMBRE
            FROM TBL_CLIENTE
            WHERE REGEXP_LIKE(NOMBRE, '^' || p_letra);

        v_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE;
        v_nombre TBL_CLIENTE.NOMBRE%TYPE;
    BEGIN
        OPEN c_clientes;
        LOOP
            FETCH c_clientes INTO v_id_cliente, v_nombre;
            EXIT WHEN c_clientes%NOTFOUND;

            dbms_output.put_line('ID: ' || v_id_cliente || ', Nombre: ' || v_nombre);
        END LOOP;
        CLOSE c_clientes;
    END listar_clientes_por_letra;

    -- Cursor para buscar clientes que se unieron en el año y mes actual
    PROCEDURE listar_clientes_mes_actual AS
        CURSOR c_clientes IS
            SELECT ID_CLIENTE, NOMBRE, FECHAINGRESO
            FROM TBL_CLIENTE
            WHERE EXTRACT(MONTH FROM FECHAINGRESO) = EXTRACT(MONTH FROM SYSDATE)
              AND EXTRACT(YEAR FROM FECHAINGRESO) = EXTRACT(YEAR FROM SYSDATE);

        v_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE;
        v_nombre TBL_CLIENTE.NOMBRE%TYPE;
        v_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE;
    BEGIN
        OPEN c_clientes;
        LOOP
            FETCH c_clientes INTO v_id_cliente, v_nombre, v_fechaingreso;
            EXIT WHEN c_clientes%NOTFOUND;

            dbms_output.put_line('ID: ' || v_id_cliente || ', Nombre: ' || v_nombre || ', Fecha de Ingreso: ' || TO_CHAR(v_fechaingreso, 'DD-MON-YY'));
        END LOOP;
        CLOSE c_clientes;
    END listar_clientes_mes_actual;

    -- Función para consultar cliente por cédula
    FUNCTION consultar_cliente_con_cedula(p_cedula NUMBER) RETURN VARCHAR2 IS
        v_cedula TBL_CLIENTE.CEDULA%TYPE;
        v_nombre TBL_CLIENTE.NOMBRE%TYPE;
    BEGIN
        SELECT C.CEDULA, C.NOMBRE
        INTO v_cedula, v_nombre
        FROM TBL_CLIENTE C
        WHERE C.CEDULA = p_cedula;
        
        RETURN 'EL CLIENTE CON CEDULA: ' || v_cedula || ' SE LLAMA: ' || v_nombre;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'EL CLIENTE CON CEDULA: ' || p_cedula || ' NO FUE ENCONTRADO';
        WHEN OTHERS THEN
            RETURN 'ERROR AL CONSULTAR LA CEDULA';
    END consultar_cliente_con_cedula;

    -- Función para consultar cliente por nombre
    FUNCTION consultar_cliente_por_nombre(p_nombre VARCHAR2) RETURN VARCHAR2 IS
        v_nombre_completo VARCHAR2(100);
    BEGIN
        SELECT C.NOMBRE || ' ' || C.APELLIDO
        INTO v_nombre_completo
        FROM TBL_CLIENTE C
        WHERE REGEXP_LIKE(C.NOMBRE, p_nombre, 'i');
        
        RETURN 'EL CLIENTE CON NOMBRE: ' || p_nombre || ' FUE ENCONTRADO Y SU NOMBRE COMPLETO ES: ' || v_nombre_completo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'EL CLIENTE CON NOMBRE: ' || p_nombre || ' NO FUE ENCONTRADO';
        WHEN OTHERS THEN
            RETURN 'ERROR AL CONSULTAR EL NOMBRE';
    END consultar_cliente_por_nombre;
END pkg_cliente_utilidades;
/

-- Crear vistas
CREATE OR REPLACE VIEW vista_listar_clientes AS 
SELECT CEDULA || ' ' || UPPER(NOMBRE) || ' ' || UPPER(APELLIDO) AS "INFORMACION PERSONAL", 
       FECHAINGRESO AS "Fecha de ingreso" 
FROM TBL_CLIENTE 
ORDER BY NOMBRE 
WITH READ ONLY;

CREATE OR REPLACE VIEW vista_cantidad_de_clientes AS 
SELECT COUNT(CEDULA) AS "CANTIDAD DE CLIENTES" 
FROM TBL_CLIENTE 
WITH READ ONLY;

--Probando Insercion
-- Inserciones de ejemplo en la tabla TBL_CLIENTE
EXEC pkg_cliente.sp_insertar_cliente(222, 1254352, 'Dylan', 'CANDIA', 9876543, '25-JUL-24', 'Avenida 1');
EXEC pkg_cliente.sp_leer_cliente(222);
EXEC pkg_cliente.sp_actualizar_cliente(222, 987654535, 'DYLAN', 'Candia', 654874687, sysdate, 'Avenida 2');
EXEC pkg_cliente.sp_eliminar_cliente(5);
EXEC pkg_cliente.sp_listar_clientes;

-- Inserción 1
EXEC pkg_cliente.sp_insertar_cliente(1, 246813579, 'Marshall', 'Zarate', 98765432, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Calle Falsa 123, Ciudad Ficticia');
EXEC pkg_cliente.sp_insertar_cliente(2, 1357924, 'Luis', 'Guerra', 12345678, TO_DATE('2024-02-20', 'YYYY-MM-DD'), 'Avenida Siempre Viva 742, Ciudad Real');
EXEC pkg_cliente.sp_insertar_cliente(3, 8642097, 'Rocío', 'Jimenez', 24681357, TO_DATE('2024-03-10', 'YYYY-MM-DD'), 'Boulevard de los Sueños 100, Villa Esperanza');
EXEC pkg_cliente.sp_insertar_cliente(4, 999999, 'Juan', 'Carmona', 13579246, TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'Plaza Mayor 500, Ciudad Dorada');
EXEC pkg_cliente.sp_insertar_cliente(5, 5050505, 'Wanda', 'Nara', 86420971, TO_DATE('2024-05-25', 'YYYY-MM-DD'), 'Calle del Sol 50, Colina Verde');
EXEC pkg_cliente.sp_insertar_cliente(6, 12345678, 'Ana', 'García', 5551234, TO_DATE('2024-07-15', 'YYYY-MM-DD'), 'Calle Principal 1, Ciudad A');
EXEC pkg_cliente.sp_insertar_cliente(7, 23456789, 'Luis', 'Martínez', 5555678, TO_DATE('2024-07-20', 'YYYY-MM-DD'), 'Calle Secundaria 2, Ciudad B');
EXEC pkg_cliente.sp_insertar_cliente(8, 34567890, 'Marta', 'Rodríguez', 5559101, TO_DATE('2024-07-25', 'YYYY-MM-DD'), 'Avenida Libertad 3, Ciudad C');
EXEC pkg_cliente.sp_insertar_cliente(9, 45678901, 'Pedro', 'Fernández', 5551122, TO_DATE('2024-08-01', 'YYYY-MM-DD'), 'Plaza Mayor 4, Ciudad D');

EXEC pkg_cliente.sp_leer_cliente(1);
EXEC pkg_cliente.sp_leer_cliente(2);
EXEC pkg_cliente.sp_leer_cliente(3);
EXEC pkg_cliente.sp_leer_cliente(4);

EXEC pkg_cliente.sp_actualizar_cliente(6, 12345678, 'Ana', 'García', 5551234, TO_DATE('2024-08-10', 'YYYY-MM-DD'), 'Calle Nueva 1, Ciudad A');
EXEC pkg_cliente.sp_actualizar_cliente(7, 23456789, 'Luis', 'Martínez', 5555678, TO_DATE('2024-08-15', 'YYYY-MM-DD'), 'Calle Modificada 2, Ciudad B');
EXEC pkg_cliente.sp_actualizar_cliente(8, 34567890, 'Marta', 'Rodríguez', 5559101, TO_DATE('2024-08-20', 'YYYY-MM-DD'), 'Avenida Cambiada 3, Ciudad C');
EXEC pkg_cliente.sp_actualizar_cliente(9, 45678901, 'Pedro', 'Fernández', 5551122, TO_DATE('2024-08-25', 'YYYY-MM-DD'), 'Plaza Actualizada 4, Ciudad D');

EXEC pkg_cliente.sp_eliminar_cliente(6);
EXEC pkg_cliente.sp_eliminar_cliente(7);
EXEC pkg_cliente.sp_eliminar_cliente(8);
EXEC pkg_cliente.sp_eliminar_cliente(9);

EXEC pkg_cliente_utilidades.listar_clientes_por_letra('A');
EXEC pkg_cliente_utilidades.listar_clientes_por_letra('L');
EXEC pkg_cliente_utilidades.listar_clientes_por_letra('C');
EXEC pkg_cliente_utilidades.listar_clientes_por_letra('M');

SELECT pkg_cliente_utilidades.consultar_cliente_con_cedula(56789012) FROM DUAL;
SELECT pkg_cliente_utilidades.consultar_cliente_con_cedula(67890123) FROM DUAL;
SELECT pkg_cliente_utilidades.consultar_cliente_con_cedula(78901234) FROM DUAL;
SELECT pkg_cliente_utilidades.consultar_cliente_con_cedula(89012345) FROM DUAL;

SELECT pkg_cliente_utilidades.consultar_cliente_por_nombre('Luis') FROM DUAL;
SELECT pkg_cliente_utilidades.consultar_cliente_por_nombre('Juan') FROM DUAL;
SELECT pkg_cliente_utilidades.consultar_cliente_por_nombre('Ana') FROM DUAL;
SELECT pkg_cliente_utilidades.consultar_cliente_por_nombre('Pedro') FROM DUAL;


EXEC pkg_cliente_utilidades.listar_clientes_mes_actual;


--LLAMAR A LA VISTA CLIENTE
SELECT "INFORMACION PERSONAL", "Fecha de ingreso" FROM VISTA_LISTAR_CLIENTES;
SELECT "CANTIDAD DE CLIENTES" from VISTA_CANTIDAD_DE_CLIENTES;

--Llamando funciones de Cliente
SELECT pkg_cliente_utilidades.consultar_cliente_con_cedula(505050505) FROM DUAL;
SELECT pkg_cliente_utilidades.consultar_cliente_por_nombre('DYLAN') FROM DUAL;




