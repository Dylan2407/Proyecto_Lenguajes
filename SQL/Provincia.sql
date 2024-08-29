SET SERVEROUTPUT ON;

-- Verifica que no exista la tabla
DECLARE
    tabla VARCHAR2(15) := 'TBL_PROVINCIA';
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ' || tabla;
  DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' NO EXISTE');
END;
/

--Crear tabla
CREATE TABLE TBL_PROVINCIA(
    ID_PROVINCIA NUMBER NOT NULL PRIMARY KEY,
    NOMBRE_PROVINCIA VARCHAR2(50) NOT NULL
);

CREATE OR REPLACE PACKAGE pkg_provincia_utilidades AS
    -- Declaración de procedimientos y funciones
    PROCEDURE insertar_provincia(
        p_id_provincia TBL_PROVINCIA.ID_PROVINCIA%TYPE,
        p_nombre_provincia TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE
    );

    PROCEDURE actualizar_provincia(
        p_id_provincia IN TBL_PROVINCIA.ID_PROVINCIA%TYPE,
        p_nuevo_nombre_provincia IN TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE
    );

    PROCEDURE eliminar_provincia(
        p_id_provincia IN TBL_PROVINCIA.ID_PROVINCIA%TYPE
    );

    PROCEDURE leer_provincia(
        p_id_provincia NUMBER
    );

    FUNCTION consultar_provincia(
        id_provincia NUMBER
    ) RETURN VARCHAR2;
END pkg_provincia_utilidades;
/

CREATE OR REPLACE PACKAGE BODY pkg_provincia_utilidades AS
    -- Procedimiento para insertar provincia
    PROCEDURE insertar_provincia(
        p_id_provincia TBL_PROVINCIA.ID_PROVINCIA%TYPE,
        p_nombre_provincia TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_PROVINCIA
        WHERE ID_PROVINCIA = p_id_provincia;

        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('YA EXISTE UN REGISTRO CON EL ID ' || p_id_provincia);
        ELSE
            INSERT INTO TBL_PROVINCIA (ID_PROVINCIA, NOMBRE_PROVINCIA)
            VALUES (p_id_provincia, p_nombre_provincia);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('REGISTRO REALIZADO');
        END IF;
    END insertar_provincia;

    -- Procedimiento para actualizar provincia
    PROCEDURE actualizar_provincia(
        p_id_provincia IN TBL_PROVINCIA.ID_PROVINCIA%TYPE,
        p_nuevo_nombre_provincia IN TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE
    ) IS
    BEGIN
        UPDATE TBL_PROVINCIA
        SET NOMBRE_PROVINCIA = p_nuevo_nombre_provincia
        WHERE ID_PROVINCIA = p_id_provincia;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Registro actualizado exitosamente');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontró un registro con el ID ' || p_id_provincia);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al procesar la operación');
    END actualizar_provincia;

    -- Procedimiento para eliminar provincia
    PROCEDURE eliminar_provincia(
        p_id_provincia IN TBL_PROVINCIA.ID_PROVINCIA%TYPE
    ) IS
    BEGIN
        DELETE FROM TBL_PROVINCIA
        WHERE ID_PROVINCIA = p_id_provincia;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Registro eliminado exitosamente');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontró un registro con el ID ' || p_id_provincia);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al procesar la operación');
    END eliminar_provincia;

    -- Procedimiento para leer datos de una provincia
    PROCEDURE leer_provincia(
        p_id_provincia NUMBER
    ) IS
        v_id_provincia TBL_PROVINCIA.ID_PROVINCIA%TYPE;
        v_nombre_provincia TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE;
    BEGIN    
        SELECT ID_PROVINCIA, NOMBRE_PROVINCIA
        INTO v_id_provincia, v_nombre_provincia
        FROM TBL_PROVINCIA
        WHERE ID_PROVINCIA = p_id_provincia;
        
        DBMS_OUTPUT.PUT_LINE('ID DE LA PROVINCIA: ' || v_id_provincia || ', EL NOMBRE DE LA PROVINCIA ES: ' || v_nombre_provincia);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('LA PROVINCIA CON EL ID ' || p_id_provincia || ' NO FUE ENCONTRADA.');
    END leer_provincia;

    -- Función para consultar provincia por ID
    FUNCTION consultar_provincia(
        id_provincia NUMBER
    ) RETURN VARCHAR2 IS
        nombre_provincia TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE;
    BEGIN
        -- Buscar el nombre de la provincia en la tabla TBL_PROVINCIA
        SELECT NOMBRE_PROVINCIA 
        INTO nombre_provincia
        FROM TBL_PROVINCIA
        WHERE ID_PROVINCIA = id_provincia;

        -- Retornar el resultado
        RETURN 'EL NOMBRE DE LA PROVINCIA ES ' || nombre_provincia;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'PROVINCIA NO ENCONTRADA';
        WHEN OTHERS THEN
            RETURN 'ERROR AL CONSULTAR LA PROVINCIA';
    END consultar_provincia;
END pkg_provincia_utilidades;
/

-- Crear vistas
CREATE OR REPLACE VIEW vista_listar_provincias AS 
SELECT ID_PROVINCIA "NUMERO DE PROVINCIA", 
       UPPER(NOMBRE_PROVINCIA) "NOMBRE DE LA PROVINCIA" 
FROM TBL_PROVINCIA 
ORDER BY ID_PROVINCIA 
WITH READ ONLY;

CREATE OR REPLACE VIEW vista_cantidad_de_provincias AS 
SELECT COUNT(ID_PROVINCIA) "CANTIDAD DE PROVINCIAS" 
FROM TBL_PROVINCIA 
WITH READ ONLY;

-- Bloque CRUD con SPs para TBL_PROVINCIA
exec pkg_provincia_utilidades.insertar_provincia(1,'San José');
exec pkg_provincia_utilidades.insertar_provincia(2,'Alajuela');
exec pkg_provincia_utilidades.insertar_provincia(3,'Cartago');
exec pkg_provincia_utilidades.insertar_provincia(4,'Heredia');
exec pkg_provincia_utilidades.insertar_provincia(5,'Guanacaste');
exec pkg_provincia_utilidades.insertar_provincia(6,'Puntarenas');
exec pkg_provincia_utilidades.insertar_provincia(7,'Limón');

-- exec pkg_provincia_utilidades.sp_actualizar_provincia(1, 'Colorado');
-- exec pkg_provincia_utilidades.sp_eliminar_provincia(1);
exec pkg_provincia_utilidades.sp_leer_provincia(2);

-- Llamando la vista Provincia
SELECT "NUMERO DE PROVINCIA", "NOMBRE DE LA PROVINCIA" FROM vista_listar_provincias;
SELECT "CANTIDAD DE PROVINCIAS" FROM vista_cantidad_de_provincias;

-- Llamando función
SELECT pkg_provincia_utilidades.consultar_provincia(4) AS resultado FROM DUAL;

-- Llamada alternativa a la función
DECLARE
    resultado VARCHAR2(100);
BEGIN
    resultado := pkg_provincia_utilidades.consultar_provincia(5);
    DBMS_OUTPUT.PUT_LINE(resultado);
END;
/



