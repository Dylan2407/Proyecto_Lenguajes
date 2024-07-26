SET SERVEROUTPUT ON;

CREATE TABLE TBL_CLIENTE (
ID_CLIENTE NUMBER NOT NULL PRIMARY KEY,
CEDULA NUMBER NOT NULL,
NOMBRE VARCHAR(20) NOT NULL,
APELLIDO VARCHAR(30) NOT NULL,
TELEFONO NUMBER NOT NULL,
FECHAINGRESO DATE NOT NULL,
DIRECCION VARCHAR(50)
);

-- PROCEDIMIENTO PARA REGISTRAR CLIENTES
CREATE OR REPLACE PROCEDURE sp_insertar_cliente(
    p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE,
    p_cedula TBL_CLIENTE.CEDULA%TYPE,
    p_nombre TBL_CLIENTE.NOMBRE%TYPE,
    p_apellido TBL_CLIENTE.APELLIDO%TYPE,
    p_telefono TBL_CLIENTE.TELEFONO%TYPE,
    p_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE,
    p_direccion TBL_CLIENTE.DIRECCION%TYPE
) as
    v_count NUMBER;
begin
    select count(*)
    into v_count
    from TBL_CLIENTE
    where ID_CLIENTE = p_id_cliente;

    if v_count > 0 then
        dbms_output.put_line('YA EXISTE UN REGISTRO CON EL ID ' || p_id_cliente);
    else
        insert into TBL_CLIENTE(ID_CLIENTE, CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION)
        values (p_id_cliente, p_cedula, p_nombre, p_apellido, p_telefono, p_fechaingreso, p_direccion);
        commit;
        dbms_output.put_line('REGISTRO REALIZADO');
    end if;
end;


-- PROCEDIMIENTO PARA LEER DATOS DE UN CLIENTE
CREATE OR REPLACE PROCEDURE sp_leer_cliente(
    p_id_cliente NUMBER
) is
    v_cedula TBL_CLIENTE.CEDULA%TYPE;
    v_nombre TBL_CLIENTE.NOMBRE%TYPE;
    v_apellido TBL_CLIENTE.APELLIDO%TYPE;
    v_telefono TBL_CLIENTE.TELEFONO%TYPE;
    v_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE;
    v_direccion TBL_CLIENTE.DIRECCION%TYPE;
begin    
    select CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION
    into v_cedula, v_nombre, v_apellido, v_telefono, v_fechaingreso, v_direccion
    from TBL_CLIENTE
    where ID_CLIENTE = p_id_cliente;
    
    dbms_output.put_line('CEDULA: ' || v_cedula || ', NOMBRE: ' || v_nombre || ', APELLIDO: ' || v_apellido || ', TELEFONO: ' || v_telefono || ', FECHAINGRESO: ' || v_fechaingreso || ', DIRECCION: ' || v_direccion);
    
exception
    when no_data_found then
    dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' NO FUE ENCONTRADO.');
end;


-- PROCEDIMIENTO PARA ACTUALIZAR UN CLIENTE
CREATE OR REPLACE PROCEDURE sp_actualizar_cliente(
    p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE,
    p_cedula TBL_CLIENTE.CEDULA%TYPE,
    p_nombre TBL_CLIENTE.NOMBRE%TYPE,
    p_apellido TBL_CLIENTE.APELLIDO%TYPE,
    p_telefono TBL_CLIENTE.TELEFONO%TYPE,
    p_fechaingreso TBL_CLIENTE.FECHAINGRESO%TYPE,
    p_direccion TBL_CLIENTE.DIRECCION%TYPE
) as
    v_count NUMBER;
begin
    select count(*)
    into v_count
    from TBL_CLIENTE
    where ID_CLIENTE = p_id_cliente;

    if v_count > 0 then
        update TBL_CLIENTE
        set CEDULA = p_cedula, NOMBRE = p_nombre, APELLIDO = p_apellido, TELEFONO = p_telefono, FECHAINGRESO = p_fechaingreso, DIRECCION = p_direccion
        where ID_CLIENTE = p_id_cliente;
        commit;
        dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' HA SIDO ACTUALIZADO.');
    else 
        dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' NO FUE ENCONTRADO.');
    end if;
end;


-- PROCEDIMIENTO PARA ELIMINAR UN CLIENTE
CREATE OR REPLACE PROCEDURE sp_eliminar_cliente(
    p_id_cliente TBL_CLIENTE.ID_CLIENTE%TYPE
) as
    v_count NUMBER;
begin
    select count(*)
    into v_count
    from TBL_CLIENTE
    where ID_CLIENTE = p_id_cliente;

    if v_count > 0 then
        delete from TBL_CLIENTE
        where ID_CLIENTE = p_id_cliente;
        commit;
        dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' FUE ELIMINADO CORRECTAMENTE.');
    else
        dbms_output.put_line('EL CLIENTE CON EL ID ' || p_id_cliente || ' NO FUE ENCONTRADO.');
    end if;
end;

EXEC sp_insertar_cliente(1, 12543523, 'Dylan','CANDIA', 987654321, '25-JUL-24', 'Avenida 1');
EXEC sp_leer_cliente(1);
EXEC sp_actualizar_cliente(1, 987654535, 'DYLAN', 'Candia', 654874687, '20-JUL-24', 'Avenida 2');
EXEC sp_eliminar_cliente(1);

--PROCEDIMIENTO PARA LISTAR TODOS LOS CLIENTES REGISTRADOS
CREATE OR REPLACE PROCEDURE SP_LISTAR_CLIENTES as
begin
    for cliente in (select ID_CLIENTE, CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION from TBL_CLIENTE) loop
        dbms_output.put_line('ID: ' || cliente.ID_CLIENTE || ', CEDULA: ' || cliente.CEDULA || ', NOMBRE: ' || cliente.NOMBRE || ', APELLIDO: ' || cliente.APELLIDO || ', TELEFONO: ' || cliente.TELEFONO || ', FECHA INGRESO: ' || cliente.FECHAINGRESO || ', DIRECCION: ' || cliente.DIRECCION);
    end loop;
end;

--PROCEDIMIENTO PARA BUSCAR CLIENTES QUE SE REGISTRARON EN UN RANGO DE FECHAS
CREATE OR REPLACE PROCEDURE SP_BUSCAR_CLIENTES_POR_RANGO_FECHA(
    p_fecha_inicio TBL_CLIENTE.FECHAINGRESO%TYPE,
    p_fecha_fin TBL_CLIENTE.FECHAINGRESO%TYPE
) as
    v_count NUMBER;
begin
    select count(*)
    into v_count
    from TBL_CLIENTE
    where FECHAINGRESO between p_fecha_inicio and p_fecha_fin;

    if v_count = 0 then
        dbms_output.put_line('NO SE ENCONTRARON CLIENTES EN EL RANGO DE FECHAS ESPECIFICADO.');
    else
        for cliente in (select ID_CLIENTE, CEDULA, NOMBRE, APELLIDO, TELEFONO, FECHAINGRESO, DIRECCION
                        from TBL_CLIENTE
                        where FECHAINGRESO between p_fecha_inicio and p_fecha_fin) loop
            dbms_output.put_line('ID: ' || cliente.ID_CLIENTE || ', CEDULA: ' || cliente.CEDULA || ', NOMBRE: ' || cliente.NOMBRE || ', APELLIDO: ' || cliente.APELLIDO || ', TELEFONO: ' || cliente.TELEFONO || ', FECHA INGRESO: ' || cliente.FECHAINGRESO || ', DIRECCION: ' || cliente.DIRECCION);
        end loop;
    end if;
end;


EXEC SP_LISTAR_CLIENTES;
EXEC SP_BUSCAR_CLIENTES_POR_RANGO_FECHA(TO_DATE('01-JUL-24', 'DD-MON-YY'), TO_DATE('31-JUL-24', 'DD-MON-YY'));

--CURSOR PARA BUSCAR CLIENTES QUE EMPIECEN CON UNA LETRA EN ESPECIFICO
DECLARE
    CURSOR c_clientes IS
        SELECT ID_CLIENTE, NOMBRE
        FROM TBL_CLIENTE
        WHERE REGEXP_LIKE(NOMBRE, '^D');

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
END;

--CURSOR PARA BUSCAR CLIENTES QUE SE UNIERON EN EL AÑO Y MES ACTUAL
DECLARE
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
END;
/

--VISTA PARA LISTAR TODOS LOS CLIENTES
CREATE OR REPLACE VIEW VISTA_LISTAR_CLIENTES AS 
SELECT CEDULA || ' ' || Upper(NOMBRE) || ' ' || Upper(APELLIDO) "INFORMACION PERSONAL", FECHAINGRESO "Fecha de ingreso" FROM TBL_CLIENTE ORDER BY NOMBRE WITH READ ONLY;

--VISTA PARA VER LA CANTIDAD DE CANTONES EN EL PAÍS
CREATE OR REPLACE VIEW VISTA_CANTIDAD_DE_CLIENTES AS 
SELECT COUNT(CEDULA) "CANTIDAD DE CLIENTES" FROM TBL_CLIENTE WITH READ ONLY;

--LLAMAR A LA VISTA CLIENTE
SELECT "INFORMACION PERSONAL", "Fecha de ingreso" FROM VISTA_LISTAR_CLIENTES;
SELECT "CANTIDAD DE CLIENTES" from VISTA_CANTIDAD_DE_CLIENTES;
