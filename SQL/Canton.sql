-- Verifica que no exista la tabla
DECLARE
    tabla1 VARCHAR2(15) := 'TBL_CANTON';
    tabla2 VARCHAR2(20) := 'TBL_CANTON_AUDIT';
    secuencia varchar(15) := 'SEQ_AUDIT_ID';
BEGIN
    -- Intentar eliminar ambas tablas
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || tabla1 || ' CASCADE CONSTRAINTS';
        DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla1 || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -942 THEN  -- ORA-00942: table or view does not exist
                DBMS_OUTPUT.PUT_LINE('ERROR: LA TABLA ' || tabla1 || ' NO EXISTE.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('ERROR AL ELIMINAR LA TABLA ' || tabla1 || ': ' || SQLERRM);
            END IF;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || tabla2;
        DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla2 || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -942 THEN  -- ORA-00942: table or view does not exist
                DBMS_OUTPUT.PUT_LINE('ERROR: LA TABLA ' || tabla2 || ' NO EXISTE.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('ERROR AL ELIMINAR LA TABLA ' || tabla2 || ': ' || SQLERRM);
            END IF;
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || SECUENCIA;
        DBMS_OUTPUT.PUT_LINE('LA SECUENCIA ' || SECUENCIA || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -942 THEN  -- ORA-00942: table or view does not exist
                DBMS_OUTPUT.PUT_LINE('ERROR: LA SECUENCIA ' || SECUENCIA || ' NO EXISTE.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('ERROR AL ELIMINAR LA SECUENCIA ' || SECUENCIA || ': ' || SQLERRM);
            END IF;
    END;
END;
/

--Crear tabla
CREATE TABLE TBL_CANTON(
    ID_CANTON NUMBER NOT NULL PRIMARY KEY,
    NOMBRE_CANTON VARCHAR2(50) NOT NULL,
    ID_PROVINCIA NUMBER,
    OPERATION_TYPE VARCHAR2(10),
    CONSTRAINT FK_CANTON_PROVINCIA
    FOREIGN KEY (ID_PROVINCIA)
    REFERENCES TBL_PROVINCIA(ID_PROVINCIA)
);

-- Tabla para auditar los registros
CREATE TABLE TBL_CANTON_AUDIT (
    ID_AUDIT NUMBER PRIMARY KEY,
    ID_CANTON NUMBER,
    NOMBRE_CANTON VARCHAR2(50),
    ID_PROVINCIA NUMBER,
    INSERT_DATE TIMESTAMP,
    OPERATION_TYPE VARCHAR2(10)    
);

--Sequencia para tabla audit
CREATE SEQUENCE SEQ_AUDIT_ID
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Creando un paquete para manejar variable global
CREATE OR REPLACE PACKAGE canton_pkg AS
    g_allow_update BOOLEAN := FALSE;
    g_allow_delete BOOLEAN := FALSE;
END canton_pkg;
/

-- Trigger insercion
CREATE OR REPLACE TRIGGER trg_audit_insert_canton
AFTER INSERT ON TBL_CANTON
FOR EACH ROW
BEGIN
    -- Insertar un registro en la tabla de auditoría
    INSERT INTO TBL_CANTON_AUDIT (ID_AUDIT, ID_CANTON, NOMBRE_CANTON, ID_PROVINCIA, INSERT_DATE, OPERATION_TYPE)
    VALUES (SEQ_AUDIT_ID.NEXTVAL, :NEW.ID_CANTON, :NEW.NOMBRE_CANTON, :NEW.ID_PROVINCIA, SYSTIMESTAMP, 'INSERT');
END;
/

-- Trigger para actualizar
CREATE OR REPLACE TRIGGER trg_prevent_direct_update
BEFORE UPDATE ON TBL_CANTON
BEGIN
    -- Verificar si se permite la actualización
    IF NOT canton_pkg.g_allow_update THEN
        RAISE_APPLICATION_ERROR(-20002, 'Operaciones de actualizacion directas no estan permitidas. Use el procedimiento para actualizar registros.');
    END IF;
END;
/

-- Trigger que registra operacion de actualzacion en tabla de auditoria
CREATE OR REPLACE TRIGGER trg_audit_update_canton
AFTER UPDATE ON TBL_CANTON
FOR EACH ROW
BEGIN
    -- Insertar un registro en la tabla de auditoría con detalles de la actualización
    INSERT INTO TBL_CANTON_AUDIT (ID_AUDIT, ID_CANTON, NOMBRE_CANTON, ID_PROVINCIA, INSERT_DATE, OPERATION_TYPE)
    VALUES (SEQ_AUDIT_ID.NEXTVAL, :OLD.ID_CANTON, :OLD.NOMBRE_CANTON, :OLD.ID_PROVINCIA, SYSTIMESTAMP, 'UPDATE');
END;
/

-- Trigger para borrado
CREATE OR REPLACE TRIGGER trg_prevent_direct_delete
BEFORE DELETE ON TBL_CANTON
BEGIN
    -- Verificar si se permite la borrado
    IF NOT canton_pkg.g_allow_delete THEN
    RAISE_APPLICATION_ERROR(-20001, 'Operaciones de borrado directas no estan permitidas. Use el procedimiento para eliminar registros.');
END IF;
END;
/

-- Trigger que registra operacion de borrado en tabla de auditoria
CREATE OR REPLACE TRIGGER trg_audit_delete_canton
AFTER DELETE ON TBL_CANTON
FOR EACH ROW
BEGIN
    -- Insertar un registro en la tabla de auditoría con detalles de la eliminación
    INSERT INTO TBL_CANTON_AUDIT (ID_AUDIT, ID_CANTON, NOMBRE_CANTON, ID_PROVINCIA, INSERT_DATE, OPERATION_TYPE)
    VALUES (SEQ_AUDIT_ID.NEXTVAL, :OLD.ID_CANTON, :OLD.NOMBRE_CANTON, :OLD.ID_PROVINCIA, SYSTIMESTAMP, 'DELETE');
END;
/

-- SP para insertar datos en tabla TBL_CANTON
CREATE OR REPLACE PROCEDURE SP_INSERTAR_CANTON (
    P_ID_CANTON TBL_CANTON.ID_CANTON%TYPE,
    P_NOMBRE_CANTON TBL_CANTON.NOMBRE_CANTON%TYPE,
    P_ID_PROVINCIA TBL_CANTON.ID_PROVINCIA%TYPE
) AS
    V_COUNT NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_COUNT
    FROM TBL_CANTON
    WHERE ID_CANTON = P_ID_CANTON;

    IF V_COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('YA EXISTE UN REGISTRO CON EL ID ' || P_ID_CANTON);
    ELSE
        INSERT INTO TBL_CANTON (ID_CANTON, NOMBRE_CANTON, ID_PROVINCIA)
        VALUES (P_ID_CANTON, P_NOMBRE_CANTON, P_ID_PROVINCIA);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('REGISTRO REALIZADO');
    END IF;
END;
/

--VISTA PARA LISTAR TODOS LOS CANTONES
CREATE OR REPLACE VIEW VISTA_LISTAR_CANTONES AS 
SELECT C.ID_CANTON "NUMERO DE CANTON", Upper(C.NOMBRE_CANTON) "NOMBRE DEL CANTON", Upper(P.NOMBRE_PROVINCIA) "PERTENECE A LA PROVINCIA DE" FROM TBL_CANTON C
INNER JOIN TBL_PROVINCIA P ON C.ID_PROVINCIA = P.ID_PROVINCIA
ORDER BY P.ID_PROVINCIA;

--VISTA PARA VER LA CANTIDAD DE CANTONES EN EL PAÍS
CREATE OR REPLACE VIEW VISTA_CANTIDAD_DE_CANTONES AS 
SELECT COUNT(ID_CANTON) "NUMERO DE CANTONES" FROM TBL_CANTON WITH READ ONLY;

--CURSOR PARA LISTAR LOS CANTONES QUE EMPIECEN CON UNA LETRA EN ESPECIFICO
DECLARE
    CURSOR c_cantones IS
        SELECT C.ID_CANTON, C.NOMBRE_CANTON, P.NOMBRE_PROVINCIA
        FROM TBL_CANTON C
        INNER JOIN TBL_PROVINCIA P ON C.ID_PROVINCIA = P.ID_PROVINCIA
        WHERE REGEXP_LIKE(C.NOMBRE_CANTON, '^A')
        ORDER BY P.NOMBRE_PROVINCIA, C.NOMBRE_CANTON;

    v_id_canton TBL_CANTON.ID_CANTON%TYPE;
    v_nombre_canton TBL_CANTON.NOMBRE_CANTON%TYPE;
    v_nombre_provincia TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE;
BEGIN
    OPEN c_cantones;
    LOOP
        FETCH c_cantones INTO v_id_canton, v_nombre_canton, v_nombre_provincia;
        EXIT WHEN c_cantones%NOTFOUND;

        dbms_output.put_line('Provincia: ' || v_nombre_provincia || ' -- Nombre del Cantón: ' || v_nombre_canton);
    END LOOP;
    CLOSE c_cantones;
END;
/


CREATE OR REPLACE PACKAGE pkg_canton AS
    FUNCTION consultar_canton(
        nombre_canton_in VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION consultar_canton_con_id(
        id_canton_in NUMBER
    ) RETURN VARCHAR2;
END pkg_canton;
/

CREATE OR REPLACE PACKAGE BODY pkg_canton AS

    FUNCTION consultar_canton(
        nombre_canton_in VARCHAR2
    ) RETURN VARCHAR2
    IS
        nombre_canton TBL_CANTON.NOMBRE_CANTON%TYPE;
        nombre_provincia TBL_PROVINCIA.NOMBRE_PROVINCIA%TYPE;
    BEGIN
        -- Buscar el nombre del canton en la tabla TBL_CANTON
        SELECT C.NOMBRE_CANTON, P.NOMBRE_PROVINCIA
        INTO nombre_canton, nombre_provincia
        FROM TBL_CANTON C
        INNER JOIN TBL_PROVINCIA P ON C.ID_PROVINCIA = P.ID_PROVINCIA
        WHERE REGEXP_LIKE (C.NOMBRE_CANTON, nombre_canton_in, 'i');

        -- Retornar el resultado
        RETURN 'EL CANTON CON NOMBRE: ' || nombre_canton || ' PERTENECE A LA PROVINCIA ' || nombre_provincia;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'CANTON ' || nombre_canton_in || ' NO ENCONTRADO';
        WHEN OTHERS THEN
            RETURN 'ERROR AL CONSULTAR EL CANTON';
    END;

    FUNCTION consultar_canton_con_id(
        id_canton_in NUMBER
    ) RETURN VARCHAR2
    IS
        id_canton TBL_CANTON.ID_CANTON%TYPE;
        nombre_canton TBL_CANTON.NOMBRE_CANTON%TYPE;
    BEGIN
        -- Buscar el ID del canton en la tabla TBL_CANTON
        SELECT C.ID_CANTON, C.NOMBRE_CANTON
        INTO id_canton, nombre_canton
        FROM TBL_CANTON C
        WHERE C.ID_CANTON = id_canton_in;

        -- Retornar el resultado
        RETURN 'EL CANTON CON ID: ' || id_canton || ' SE LLAMA: ' || nombre_canton;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'EL CANTON CON ID: ' || id_canton_in || ' NO FUE ENCONTRADO';
        WHEN OTHERS THEN
            RETURN 'ERROR AL CONSULTAR EL CANTON';
    END;

END pkg_canton;
/

CREATE OR REPLACE PACKAGE pkg_canton_utilidades AS
    -- Declaración de variables globales
    g_allow_update BOOLEAN := FALSE;
    g_allow_delete BOOLEAN := FALSE;

    -- Declaración de procedimientos
    PROCEDURE sp_insertar_canton (
        p_id_canton TBL_CANTON.ID_CANTON%TYPE,
        p_nombre_canton TBL_CANTON.NOMBRE_CANTON%TYPE,
        p_id_provincia TBL_CANTON.ID_PROVINCIA%TYPE
    );

    PROCEDURE sp_actualizar_canton(
        p_id_canton IN TBL_CANTON.ID_CANTON%TYPE,
        p_nuevo_nombre_canton IN TBL_CANTON.NOMBRE_CANTON%TYPE
    );

    PROCEDURE sp_eliminar_canton(
        p_id_canton IN TBL_CANTON.ID_CANTON%TYPE
    );

    PROCEDURE sp_leer_canton(
        p_id_canton NUMBER
    );
END pkg_canton_utilidades;
/

CREATE OR REPLACE PACKAGE BODY pkg_canton_utilidades AS

    -- Implementación del procedimiento para insertar cantones
    PROCEDURE sp_insertar_canton (
        p_id_canton TBL_CANTON.ID_CANTON%TYPE,
        p_nombre_canton TBL_CANTON.NOMBRE_CANTON%TYPE,
        p_id_provincia TBL_CANTON.ID_PROVINCIA%TYPE
    ) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_CANTON
        WHERE ID_CANTON = p_id_canton;

        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('YA EXISTE UN REGISTRO CON EL ID ' || p_id_canton);
        ELSE
            INSERT INTO TBL_CANTON (ID_CANTON, NOMBRE_CANTON, ID_PROVINCIA)
            VALUES (p_id_canton, p_nombre_canton, p_id_provincia);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('REGISTRO REALIZADO');
        END IF;
    END sp_insertar_canton;

    -- Implementación del procedimiento para actualizar cantones
    PROCEDURE sp_actualizar_canton(
        p_id_canton IN TBL_CANTON.ID_CANTON%TYPE,
        p_nuevo_nombre_canton IN TBL_CANTON.NOMBRE_CANTON%TYPE
    ) IS
        v_sql VARCHAR2(1000);
    BEGIN
        -- Permitir la actualización al establecer la variable global
        g_allow_update := TRUE;
        
        -- Construir la consulta de actualización
        v_sql := 'UPDATE TBL_CANTON SET NOMBRE_CANTON = ''' || p_nuevo_nombre_canton || ''' WHERE ID_CANTON = ' || p_id_canton;
        
        -- Ejecutar la consulta dinámica
        EXECUTE IMMEDIATE v_sql;
        
        -- Confirmar la actualización
        DBMS_OUTPUT.PUT_LINE('Actualización realizada con nombre de canton cambiado a: ' || p_nuevo_nombre_canton || ' y id: ' || p_id_canton);
        
        -- Restablecer la variable para bloquear futuras actualizaciones directas
        g_allow_update := FALSE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontraron registros para actualizar con la condición proporcionada.');
        WHEN OTHERS THEN
            -- Asegurarse de restablecer la variable incluso si hay un error
            g_allow_update := FALSE;
            DBMS_OUTPUT.PUT_LINE('Error en la actualización: ' || SQLERRM);
    END sp_actualizar_canton;

    -- Implementación del procedimiento para eliminar cantones
    PROCEDURE sp_eliminar_canton(
        p_id_canton IN TBL_CANTON.ID_CANTON%TYPE
    ) IS
        v_sql VARCHAR2(1000);
    BEGIN
        -- Permitir la eliminación al establecer la variable global
        g_allow_delete := TRUE;
        
        -- Construir la consulta de eliminación
        v_sql := 'DELETE FROM TBL_CANTON WHERE ID_CANTON=' || p_id_canton;
        
        -- Ejecutar la consulta dinámica
        EXECUTE IMMEDIATE v_sql;
        
        -- Confirmar la eliminación
        DBMS_OUTPUT.PUT_LINE('Eliminación realizada con condición: ' || p_id_canton);
        
        -- Restablecer la variable para bloquear futuras eliminaciones directas
        g_allow_delete := FALSE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontraron registros para eliminar con la condición proporcionada.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en la eliminación: ' || SQLERRM);
    END sp_eliminar_canton;

    -- Implementación del procedimiento para leer cantones
    PROCEDURE sp_leer_canton(
        p_id_canton NUMBER
    ) IS
        v_id_canton TBL_CANTON.ID_CANTON%TYPE;
        v_nombre_canton TBL_CANTON.NOMBRE_CANTON%TYPE;
    BEGIN    
        SELECT ID_CANTON, NOMBRE_CANTON INTO v_id_canton, v_nombre_canton
        FROM TBL_CANTON
        WHERE ID_CANTON = p_id_canton;
        
        DBMS_OUTPUT.PUT_LINE('ID DEL CANTON: ' || v_id_canton || ', EL NOMBRE DEL CANTON ES: ' || v_nombre_canton);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('EL CANTON CON EL ID ' || p_id_canton || ' NO FUE ENCONTRADO.');
    END sp_leer_canton;

END pkg_canton_utilidades;
/

--CURSOR PARA LISTAR LOS CANTONES EN UN RANGO DE ID
DECLARE
    CURSOR C_CANTONES IS
        SELECT ID_CANTON, NOMBRE_CANTON, ID_PROVINCIA
        FROM TBL_CANTON
        WHERE ID_CANTON BETWEEN 100 AND 110
        ORDER BY ID_CANTON;

    v_id_canton TBL_CANTON.ID_CANTON%TYPE;
    v_nombre_canton TBL_CANTON.NOMBRE_CANTON%TYPE;
    v_id_provincia TBL_CANTON.ID_PROVINCIA%TYPE;
BEGIN
    OPEN C_CANTONES;

    LOOP
        FETCH C_CANTONES INTO v_id_canton, v_nombre_canton, v_id_provincia;
        EXIT WHEN C_CANTONES%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID CANTON: ' || v_id_canton || ', NOMBRE DEL CANTON: ' || v_nombre_canton || ', ID PROVINCIA: ' || v_id_provincia);
    END LOOP;

    CLOSE C_CANTONES;
END;
/

-- Insercion de cantones
--San Jose
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES (101,1,'San José');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES (102,1,'Escazú');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (103,1,'Desamparados');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (104,1,'Puriscal');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (105,1,'Tarrazú');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (106,1,'Aserrí');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (107,1,'Mora');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (108,1,'Goicoechea');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (109,1,'Santa Ana');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (110,1,'Alajuelita');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (111,1,'Vasquez de Coronado');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (112,1,'Acosta');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (113,1,'Tibás');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (114,1,'Moravia');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (115,1,'Montes de Oca');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (116,1,'Turrubares');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (117,1,'Dota');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (118,1,'Curridabat');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (119,1,'Pérez Zeledón');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (120,1,'León Cortés');

--Alajuela
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (201,2,'Alajuela');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (202,2,'San Ramón');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (203,2,'Grecia');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (204,2,'San Mateo');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (205,2,'Atenas');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (206,2,'Naranjo');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (207,2,'Palmares');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (208,2,'Poás');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (209,2,'Orotina');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (210,2,'San Carlos');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (211,2,'Zarcero');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (212,2,'Sarchí');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (213,2,'Upala');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (214,2,'Los Chiles');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (215,2,'Guatuso');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (216,2,'Río Cuarto');

--Cartago
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (301,3,'Cartago');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (302,3,'Paraíso');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (303,3,'La Unión');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (304,3,'Jiménez');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (305,3,'Turrialba');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (306,3,'Alvarado');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (307,3,'Oreamuno');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (308,3,'El Guarco');

--Heredia
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (401,4,'Heredia');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (402,4,'Barva');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (403,4,'Santo Domingo');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (404,4,'Santa Bárbara');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (405,4,'San Rafael');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (406,4,'San Isidro');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (407,4,'Belén');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (408,4,'Flores');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (409,4,'San Pablo');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (410,4,'Sarapiquí');

--Guanacaste
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (501,5,'Liberia');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (502,5,'Nicoya');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (503,5,'Santa Cruz');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (504,5,'Bagaces');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (505,5,'Carrillo');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (506,5,'Cañas');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (507,5,'Abangares');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (508,5,'Tilarán');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (509,5,'Nandayure');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (510,5,'La Cruz');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (511,5,'Hojancha');

--Puntarenas
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (601,6,'Puntarenas');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (602,6,'Esparza');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (603,6,'Buenos Aires');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (604,6,'Montes de Oro');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (605,6,'Osa');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (606,6,'Aguirre');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (607,6,'Golfito');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (608,6,'Coto Brus');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (609,6,'Parrita');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (610,6,'Corredores');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (611,6,'Garabito');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (612,6,'Monteverde');

--Limon
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (701,7,'Limón');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (702,7,'Pococí');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (703,7,'Siquirres ');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (704,7,'Talamanca');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (705,7,'Matina');
INSERT INTO TBL_CANTON (ID_CANTON,ID_PROVINCIA,NOMBRE_CANTON) VALUES  (706,7,'Guácimo');

BEGIN pkg_canton_utilidades.sp_insertar_canton(777, 'test', 1);END;
/
BEGIN pkg_canton_utilidades.sp_actualizar_canton(777, 'test2'); END;
/
BEGIN pkg_canton_utilidades.sp_eliminar_canton(777); END;
/
BEGIN pkg_canton_utilidades.sp_leer_canton(777); END;
/

--Llamando la vista Canton
SELECT "NUMERO DE CANTON", "NOMBRE DEL CANTON", "PERTENECE A LA PROVINCIA DE" FROM VISTA_LISTAR_CANTONES;
SELECT "NUMERO DE CANTONES" FROM VISTA_CANTIDAD_DE_CANTONES;

--Llamando funciones de Canton
SELECT pkg_canton.consultar_canton('MorAvIa') AS RESULTADO FROM DUAL;
SELECT pkg_canton.consultar_canton('SaN rAfAEl') AS RESULTADO FROM DUAL;
SELECT pkg_canton.consultar_canton_con_id(103) AS RESULTADO FROM DUAL;



