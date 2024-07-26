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

-- SP para insertar datos en tabla TBL_PROVINCIA
CREATE OR REPLACE PROCEDURE SP_INSERTAR_PROVINCIA (
    P_ID_PROVINCIA TBL_PROVINCIA.ID_PROVINCIA%TYPE,
    P_NOMBRE_PROVINCIA TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE
) AS
    V_COUNT NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_COUNT
    FROM TBL_PROVINCIA
    WHERE ID_PROVINCIA = P_ID_PROVINCIA;

    IF V_COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('YA EXISTE UN REGISTRO CON EL ID ' || P_ID_PROVINCIA);
    ELSE
        INSERT INTO TBL_PROVINCIA (ID_PROVINCIA, NOMBRE_PROVINCIA)
        VALUES (P_ID_PROVINCIA, P_NOMBRE_PROVINCIA);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('REGISTRO REALIZADO');
    END IF;
END;
/

-- SP para actualizar datos en tabla TBL_PROVINCIA
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PROVINCIA (
    P_ID_PROVINCIA IN TBL_PROVINCIA.ID_PROVINCIA%TYPE,
    P_NUEVO_NOMBRE_PROVINCIA IN TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE
) IS
BEGIN
    UPDATE TBL_PROVINCIA
    SET NOMBRE_PROVINCIA = P_NUEVO_NOMBRE_PROVINCIA
    WHERE ID_PROVINCIA = P_ID_PROVINCIA;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Registro actualizado exitosamente');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontr� un registro con el ID ' || P_ID_PROVINCIA);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al procesar la operaci�n');
END SP_ACTUALIZAR_PROVINCIA;
/

-- SP para eliminar datos en tabla TBL_PROVINCIA
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PROVINCIA (
    P_ID_PROVINCIA IN TBL_PROVINCIA.ID_PROVINCIA%TYPE
) IS
BEGIN
    DELETE FROM TBL_PROVINCIA
    WHERE ID_PROVINCIA = P_ID_PROVINCIA;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Registro eliminado exitosamente');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontr� un registro con el ID ' || P_ID_PROVINCIA);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al procesar la operaci�n');
END SP_ELIMINAR_PROVINCIA;
/

-- SP para leer datos en tabla TBL_PROVINCIA
CREATE OR REPLACE PROCEDURE SP_LEER_PROVINCIA(
    P_ID_PROVINCIA NUMBER
)IS
    V_ID_PROVINCIA TBL_PROVINCIA.ID_PROVINCIA%TYPE;
    V_NOMBRE_PROVINCIA TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE;
BEGIN    
    SELECT ID_PROVINCIA, NOMBRE_PROVINCIA INTO V_ID_PROVINCIA, V_NOMBRE_PROVINCIA
    FROM TBL_PROVINCIA
    WHERE ID_PROVINCIA = P_ID_PROVINCIA;
    
    DBMS_OUTPUT.PUT_LINE('ID DE LA PROVINCIA: ' || V_ID_PROVINCIA || ', EL NOMBRE DE LA PROVINCIA ES: ' || V_NOMBRE_PROVINCIA);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('LA PROVINCIA CON EL ID ' || P_ID_PROVINCIA || ' NO FUE ENCONTRADA.');
END;
/

--VISTA PARA LISTAR TODAS LAS PROVINCIAS
CREATE OR REPLACE VIEW VISTA_LISTAR_PROVINCIAS AS 
SELECT ID_PROVINCIA "NUMERO DE PROVINCIA", Upper(NOMBRE_PROVINCIA) "NOMBRE DE LA PROVINCIA" FROM TBL_PROVINCIA ORDER BY ID_PROVINCIA WITH READ ONLY;

--VISTA PARA LISTAR CANTIDAD DE PROVINCIAS
CREATE OR REPLACE VIEW VISTA_CANTIDAD_DE_PROVINCIAS AS 
SELECT COUNT(ID_PROVINCIA) "CANTIDAD DE PROVINCIAS" FROM TBL_PROVINCIA WITH READ ONLY;

-- Bloque CRUD con SPs para TBL_PROVINCIA
exec sp_insertar_provincia(1,'San Jos�');
exec sp_insertar_provincia(2,'Alajuela');
exec sp_insertar_provincia(3,'Cartago');
exec sp_insertar_provincia(4,'Heredia');
exec sp_insertar_provincia(5,'Guanacaste');
exec sp_insertar_provincia(6,'Puntarenas');
exec sp_insertar_provincia(7,'Lim�n');

//exec sp_actualizar_provincia(1, 'Colorado');
//exec sp_eliminar_provincia(1);
exec sp_leer_provincia(2);

--Llamando la vista Provincia
SELECT "NUMERO DE PROVINCIA", "NOMBRE DE LA PROVINCIA" FROM vista_listar_provincias;
SELECT "CANTIDAD DE PROVINCIAS" FROM VISTA_CANTIDAD_DE_PROVINCIAS;

