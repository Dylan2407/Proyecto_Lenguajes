SET SERVEROUTPUT ON;

-- Verifica que no exista la tabla
DECLARE
    tabla VARCHAR2(15) := 'TBL_DIRECCION';
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ' || tabla;
  DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' NO EXISTE');
END;
/
-- TABLA DE DIRECCION
CREATE TABLE TBL_DIRECCION(
    ID_DIRECCION NUMBER NOT NULL PRIMARY KEY,
    DIRECCIONCOMPLETA VARCHAR2(50) NOT NULL,
    ID_DISTRITO NUMBER NOT NULL
);

CREATE OR REPLACE PACKAGE pkg_direccion_utilidades AS
    -- Declaración de los procedimientos
    PROCEDURE sp_insertar_direccion(
        p_id_direccion TBL_DIRECCION.ID_DIRECCION%TYPE,
        p_direccioncompleta TBL_DIRECCION.DIRECCIONCOMPLETA%TYPE,
        p_id_distrito TBL_DIRECCION.ID_DISTRITO%TYPE
    );

    PROCEDURE sp_leer_direccion(
        p_id_direccion NUMBER
    );

    PROCEDURE sp_actualizar_direccion(
        p_id_direccion TBL_DIRECCION.ID_DIRECCION%TYPE,
        p_direccioncompleta TBL_DIRECCION.DIRECCIONCOMPLETA%TYPE,
        p_id_distrito TBL_DIRECCION.ID_DISTRITO%TYPE
    );

    PROCEDURE sp_eliminar_direccion(
        p_id_direccion TBL_DIRECCION.ID_DIRECCION%TYPE
    );
END pkg_direccion_utilidades;
/

CREATE OR REPLACE PACKAGE BODY pkg_direccion_utilidades AS

    -- Implementación del procedimiento para insertar direcciones
    PROCEDURE sp_insertar_direccion(
        p_id_direccion TBL_DIRECCION.ID_DIRECCION%TYPE,
        p_direccioncompleta TBL_DIRECCION.DIRECCIONCOMPLETA%TYPE,
        p_id_distrito TBL_DIRECCION.ID_DISTRITO%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_DIRECCION
        WHERE ID_DIRECCION = p_id_direccion;
        
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('YA EXISTE UN REGISTRO CON EL ID ' || p_id_direccion);
        ELSE
            INSERT INTO TBL_DIRECCION(ID_DIRECCION, DIRECCIONCOMPLETA, ID_DISTRITO)
            VALUES (p_id_direccion, p_direccioncompleta, p_id_distrito);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('REGISTRO REALIZADO');
        END IF;
    END sp_insertar_direccion;

    -- Implementación del procedimiento para leer direcciones
    PROCEDURE sp_leer_direccion(
        p_id_direccion NUMBER
    ) IS
        v_id_direccion TBL_DIRECCION.ID_DIRECCION%TYPE;
        v_direccioncompleta TBL_DIRECCION.DIRECCIONCOMPLETA%TYPE;
        v_id_distrito TBL_DIRECCION.ID_DISTRITO%TYPE;
    BEGIN    
        SELECT ID_DIRECCION, DIRECCIONCOMPLETA, ID_DISTRITO INTO v_id_direccion, v_direccioncompleta, v_id_distrito
        FROM TBL_DIRECCION
        WHERE ID_DIRECCION = p_id_direccion;
        
        DBMS_OUTPUT.PUT_LINE('ID DE LA DIRECCION: ' || v_id_direccion || ', DIRECCION COMPLETA: ' || v_direccioncompleta || ', ID_DISTRITO: ' || v_id_distrito);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('LA DIRECCION CON EL ID ' || p_id_direccion || ' NO FUE ENCONTRADA.');
    END sp_leer_direccion;

    -- Implementación del procedimiento para actualizar direcciones
    PROCEDURE sp_actualizar_direccion(
        p_id_direccion TBL_DIRECCION.ID_DIRECCION%TYPE,
        p_direccioncompleta TBL_DIRECCION.DIRECCIONCOMPLETA%TYPE,
        p_id_distrito TBL_DIRECCION.ID_DISTRITO%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_DIRECCION
        WHERE ID_DIRECCION = p_id_direccion;

        IF v_count > 0 THEN
            UPDATE TBL_DIRECCION
            SET DIRECCIONCOMPLETA = p_direccioncompleta, ID_DISTRITO = p_id_distrito
            WHERE ID_DIRECCION = p_id_direccion;
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('LA DIRECCION CON EL ID ' || p_id_direccion || ' HA SIDO ACTUALIZADA.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('LA DIRECCION CON EL ID ' || p_id_direccion || ' NO FUE ENCONTRADA.');
        END IF;
    END sp_actualizar_direccion;

    -- Implementación del procedimiento para eliminar direcciones
    PROCEDURE sp_eliminar_direccion(
        p_id_direccion TBL_DIRECCION.ID_DIRECCION%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_DIRECCION
        WHERE ID_DIRECCION = p_id_direccion;

        IF v_count > 0 THEN
            DELETE FROM TBL_DIRECCION
            WHERE ID_DIRECCION = p_id_direccion;
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('LA DIRECCION CON EL ID ' || p_id_direccion || ' FUE ELIMINADA CORRECTAMENTE.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('LA DIRECCION CON EL ID ' || p_id_direccion || ' NO FUE ENCONTRADA.');
        END IF;
    END sp_eliminar_direccion;

END pkg_direccion_utilidades;
/

-- Bloque CRUD con SPs para TBL_DIRECCION usando el paquete pkg_direccion_utilidades

-- Insertar una nueva dirección
EXEC pkg_direccion_utilidades.sp_insertar_direccion(1, 'Avenida 1 Detras Del Palo De Mangos', 1);
EXEC pkg_direccion_utilidades.sp_leer_direccion(1);
EXEC pkg_direccion_utilidades.sp_actualizar_direccion(1, 'Avenida 2 frente a la planta de chayotes', 1);

--EXEC pkg_direccion_utilidades.sp_eliminar_direccion(1);

-- Insertar direcciones adicionales
EXEC pkg_direccion_utilidades.sp_insertar_direccion(1, 'Avenida 1 Detras Del Palo De Mangos', 1);
EXEC pkg_direccion_utilidades.sp_insertar_direccion(2, 'Calle Hernandez frente al taller Juanito', 1);




--VISTA PARA LISTAR TODAS LAS DIRECCIONES
CREATE OR REPLACE VIEW VISTA_LISTAR_DIRECCIONES AS 
SELECT ID_DIRECCION, Upper(DIRECCIONCOMPLETA) "DIRECCION COMPLETA", ID_DISTRITO FROM TBL_DIRECCION ORDER BY ID_DIRECCION WITH READ ONLY;

--VISTA PARA LISTAR CANTIDAD DE DIRECCIONES
CREATE OR REPLACE VIEW VISTA_CANTIDAD_DE_DIRECCIONES AS 
SELECT COUNT(ID_DIRECCION) "CANTIDAD DE DIRECCIONES" FROM TBL_DIRECCION WITH READ ONLY;

-- Ejecucion de la vista Direccion
SELECT "DIRECCION COMPLETA", ID_DISTRITO FROM vista_listar_direcciones;
SELECT "CANTIDAD DE DIRECCIONES" FROM vista_cantidad_de_direcciones;
