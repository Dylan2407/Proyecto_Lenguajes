-- Verifica que no exista la tabla
DECLARE
    tabla VARCHAR2(15) := 'TBL_EMPLEADO';
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ' || tabla;
  DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' NO EXISTE');
END;
/

-- TABLA DE EMPLEADOS
CREATE TABLE TBL_EMPLEADO(
    ID_EMPLEADO NUMBER NOT NULL PRIMARY KEY,
    IDENTIFICACION NUMBER NOT NULL,
    NOMBRE VARCHAR(20) NOT NULL,
    APELLIDO VARCHAR(20) NOT NULL,
    SALARIO NUMBER(10,2) NOT NULL,
    ID_CLIENTE NUMBER,
    HORARIO DATE,
    CONSTRAINT FK_EMPLEADO_CLIENTE 
    FOREIGN KEY (ID_CLIENTE) 
    REFERENCES TBL_CLIENTE (ID_CLIENTE)
);

CREATE OR REPLACE PACKAGE pkg_empleado_utilidades AS
    -- Declaración de procedimientos y funciones
    PROCEDURE insertar_empleado(
        p_id_empleado TBL_EMPLEADO.ID_EMPLEADO%TYPE,
        p_identificacion TBL_EMPLEADO.IDENTIFICACION%TYPE,
        p_nombre TBL_EMPLEADO.NOMBRE%TYPE,
        p_apellido TBL_EMPLEADO.APELLIDO%TYPE,
        p_salario TBL_EMPLEADO.SALARIO%TYPE,
        p_id_cliente TBL_EMPLEADO.ID_CLIENTE%TYPE,
        p_horario TBL_EMPLEADO.HORARIO%TYPE
    );
    
    PROCEDURE leer_empleado(
        p_id_empleado NUMBER
    );
    
    PROCEDURE actualizar_empleado(
        p_id_empleado TBL_EMPLEADO.ID_EMPLEADO%TYPE,
        p_identificacion TBL_EMPLEADO.IDENTIFICACION%TYPE,
        p_nombre TBL_EMPLEADO.NOMBRE%TYPE,
        p_apellido TBL_EMPLEADO.APELLIDO%TYPE,
        p_salario TBL_EMPLEADO.SALARIO%TYPE,
        p_id_cliente TBL_EMPLEADO.ID_CLIENTE%TYPE,
        p_horario TBL_EMPLEADO.HORARIO%TYPE
    );
    
    PROCEDURE eliminar_empleado(
        p_id_empleado TBL_EMPLEADO.ID_EMPLEADO%TYPE
    );
    
    FUNCTION consultar_empleado_con_identificacion(
        p_identificacion NUMBER
    ) RETURN VARCHAR2;
    
    FUNCTION consultar_cliente_asociado_a_empleado(
        p_cedula NUMBER
    ) RETURN VARCHAR2;
END pkg_empleado_utilidades;
/

CREATE OR REPLACE PACKAGE BODY pkg_empleado_utilidades AS
    -- Procedimiento para registrar empleados
    PROCEDURE insertar_empleado(
        p_id_empleado TBL_EMPLEADO.ID_EMPLEADO%TYPE,
        p_identificacion TBL_EMPLEADO.IDENTIFICACION%TYPE,
        p_nombre TBL_EMPLEADO.NOMBRE%TYPE,
        p_apellido TBL_EMPLEADO.APELLIDO%TYPE,
        p_salario TBL_EMPLEADO.SALARIO%TYPE,
        p_id_cliente TBL_EMPLEADO.ID_CLIENTE%TYPE,
        p_horario TBL_EMPLEADO.HORARIO%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_EMPLEADO
        WHERE ID_EMPLEADO = p_id_empleado;

        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('YA EXISTE UN REGISTRO CON EL ID ' || p_id_empleado);
        ELSE
            INSERT INTO TBL_EMPLEADO(ID_EMPLEADO, IDENTIFICACION, NOMBRE, APELLIDO, SALARIO, ID_CLIENTE, HORARIO)
            VALUES (p_id_empleado, p_identificacion, p_nombre, p_apellido, p_salario, p_id_cliente, p_horario);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('REGISTRO REALIZADO');
        END IF;
    END insertar_empleado;

    -- Procedimiento para leer datos de un empleado
    PROCEDURE leer_empleado(
        p_id_empleado NUMBER
    ) IS
        v_identificacion TBL_EMPLEADO.IDENTIFICACION%TYPE;
        v_nombre TBL_EMPLEADO.NOMBRE%TYPE;
        v_apellido TBL_EMPLEADO.APELLIDO%TYPE;
        v_salario TBL_EMPLEADO.SALARIO%TYPE;
        v_id_cliente TBL_EMPLEADO.ID_CLIENTE%TYPE;
        v_horario TBL_EMPLEADO.HORARIO%TYPE;
    BEGIN    
        SELECT IDENTIFICACION, NOMBRE, APELLIDO, SALARIO, ID_CLIENTE, HORARIO
        INTO v_identificacion, v_nombre, v_apellido, v_salario, v_id_cliente, v_horario
        FROM TBL_EMPLEADO
        WHERE ID_EMPLEADO = p_id_empleado;
        
        DBMS_OUTPUT.PUT_LINE('IDENTIFICACION: ' || v_identificacion || ', NOMBRE: ' || v_nombre || ', APELLIDO: ' || v_apellido || ', SALARIO: ' || v_salario || ', ID_CLIENTE: ' || v_id_cliente || ', HORARIO: ' || v_horario);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('EL EMPLEADO CON EL ID ' || p_id_empleado || ' NO FUE ENCONTRADO.');
    END leer_empleado;

    -- Procedimiento para actualizar un empleado
    PROCEDURE actualizar_empleado(
        p_id_empleado TBL_EMPLEADO.ID_EMPLEADO%TYPE,
        p_identificacion TBL_EMPLEADO.IDENTIFICACION%TYPE,
        p_nombre TBL_EMPLEADO.NOMBRE%TYPE,
        p_apellido TBL_EMPLEADO.APELLIDO%TYPE,
        p_salario TBL_EMPLEADO.SALARIO%TYPE,
        p_id_cliente TBL_EMPLEADO.ID_CLIENTE%TYPE,
        p_horario TBL_EMPLEADO.HORARIO%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_EMPLEADO
        WHERE ID_EMPLEADO = p_id_empleado;

        IF v_count > 0 THEN
            UPDATE TBL_EMPLEADO
            SET IDENTIFICACION = p_identificacion,
                NOMBRE = p_nombre,
                APELLIDO = p_apellido,
                SALARIO = p_salario,
                ID_CLIENTE = p_id_cliente,
                HORARIO = p_horario
            WHERE ID_EMPLEADO = p_id_empleado;
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('EL EMPLEADO CON EL ID ' || p_id_empleado || ' HA SIDO ACTUALIZADO.');
        ELSE 
            DBMS_OUTPUT.PUT_LINE('EL EMPLEADO CON EL ID ' || p_id_empleado || ' NO FUE ENCONTRADO.');
        END IF;
    END actualizar_empleado;

    -- Procedimiento para eliminar un empleado
    PROCEDURE eliminar_empleado(
        p_id_empleado TBL_EMPLEADO.ID_EMPLEADO%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_EMPLEADO
        WHERE ID_EMPLEADO = p_id_empleado;

        IF v_count > 0 THEN
            DELETE FROM TBL_EMPLEADO
            WHERE ID_EMPLEADO = p_id_empleado;
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('EL EMPLEADO CON EL ID ' || p_id_empleado || ' FUE ELIMINADO CORRECTAMENTE.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('EL EMPLEADO CON EL ID ' || p_id_empleado || ' NO FUE ENCONTRADO.');
        END IF;
    END eliminar_empleado;

    -- Función para buscar empleado por identificación
    FUNCTION consultar_empleado_con_identificacion(
        p_identificacion NUMBER
    ) RETURN VARCHAR2 IS
        v_identificacion TBL_EMPLEADO.IDENTIFICACION%TYPE;
        v_nombre TBL_EMPLEADO.NOMBRE%TYPE;
    BEGIN
        SELECT IDENTIFICACION, NOMBRE || ' ' || APELLIDO
        INTO v_identificacion, v_nombre
        FROM TBL_EMPLEADO
        WHERE IDENTIFICACION = p_identificacion;
        
        RETURN 'EL EMPLEADO CON LA IDENTIFICACION: ' || v_identificacion || ' SE LLAMA: ' || v_nombre;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'EL EMPLEADO CON LA IDENTIFICACION: ' || p_identificacion || ' NO FUE ENCONTRADO';
        WHEN OTHERS THEN
            RETURN 'ERROR AL CONSULTAR LA IDENTIFICACION';
    END consultar_empleado_con_identificacion;

    -- Función para buscar cliente asociado a empleado por cédula
    FUNCTION consultar_cliente_asociado_a_empleado(
        p_cedula NUMBER
    ) RETURN VARCHAR2 IS
        v_nombre_empleado TBL_EMPLEADO.NOMBRE%TYPE;
        v_nombre_cliente TBL_CLIENTE.NOMBRE%TYPE;
    BEGIN
        SELECT E.NOMBRE || ' ' || E.APELLIDO, C.NOMBRE || ' ' || C.APELLIDO
        INTO v_nombre_empleado, v_nombre_cliente
        FROM TBL_EMPLEADO E
        INNER JOIN TBL_CLIENTE C ON E.ID_CLIENTE = C.ID_CLIENTE
        WHERE C.CEDULA = p_cedula;
        
        RETURN 'EL CLIENTE CON CEDULA: ' || p_cedula || ' FUE ENCONTRADO Y ESTÁ ASIGNADO AL EMPLEADO: ' || v_nombre_empleado;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'EL CLIENTE CON CEDULA: ' || p_cedula || ' NO FUE ENCONTRADO';
        WHEN OTHERS THEN
            RETURN 'ERROR AL CONSULTAR EL CLIENTE';
    END consultar_cliente_asociado_a_empleado;
END pkg_empleado_utilidades;
/

-- Crear vistas
CREATE OR REPLACE VIEW vista_listar_empleados AS 
SELECT IDENTIFICACION || ' ' || UPPER(NOMBRE) || ' ' || UPPER(APELLIDO) AS "INFORMACION PERSONAL", 
       HORARIO AS "HORARIO LABORAL"
FROM TBL_EMPLEADO 
ORDER BY NOMBRE 
WITH READ ONLY;

CREATE OR REPLACE VIEW vista_cantidad_de_empleados AS 
SELECT COUNT(IDENTIFICACION) AS "CANTIDAD DE EMPLEADOS" 
FROM TBL_EMPLEADO 
WITH READ ONLY;

-- Inserciones en la tabla TBL_EMPLEADO

-- Con registros en TBL_EMPLEADO con ID_CLIENTE de 1 a 5

EXEC pkg_empleado_utilidades.insertar_empleado(1, 123456789, 'Ana', 'García', 3000.00, 1, TO_DATE('2024-07-26', 'YYYY-MM-DD'));

EXEC pkg_empleado_utilidades.insertar_empleado(2, 987654321, 'Luis', 'Pérez', 3500.00, 2, TO_DATE('2024-07-26', 'YYYY-MM-DD'));

EXEC pkg_empleado_utilidades.insertar_empleado(3, 456123789, 'María', 'Rodríguez', 4000.00, 3, TO_DATE('2024-07-26', 'YYYY-MM-DD'));

EXEC pkg_empleado_utilidades.insertar_empleado(4, 321654987, 'Carlos', 'Mendoza', 3200.00, 4, TO_DATE('2024-07-26', 'YYYY-MM-DD'));

EXEC pkg_empleado_utilidades.insertar_empleado(5, 147258369, 'Lucía', 'Martínez', 2800.00, 5, TO_DATE('2024-07-26', 'YYYY-MM-DD'));


--Llamando vistas
SELECT "INFORMACION PERSONAL" FROM vista_listar_empleados;
SELECT "CANTIDAD DE EMPLEADOS" FROM vista_cantidad_de_empleados;

--Llamando funciones de empleado
SELECT pkg_empleado_utilidades.consultar_empleado_con_identificacion(123456789) RESULTADO FROM DUAL;
SELECT pkg_empleado_utilidades.consultar_cliente_asociado_a_empleado(505050505) RESULTADO FROM DUAL;


