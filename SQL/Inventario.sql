SET SERVEROUTPUT ON;

DECLARE
  tabla VARCHAR2(20):= 'TBL_INVENTARIO';
BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ' || tabla || ' CASCADE CONSTRAINTS';
  DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' FUE ENCONTRADA Y ELIMINADA EXITOSAMENTE');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('LA TABLA ' || tabla || ' NO EXISTE');
END;
/

CREATE TABLE TBL_INVENTARIO(
ID_PRODUCTO NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
CODIGO_BARRAS NUMBER NOT NULL,
NOMBRE_PRODUCTO VARCHAR2(30),
CATEGORIA VARCHAR2(30),
COSTO NUMBER,
CANTIDAD NUMBER,
CEDULA_JURIDICA_PROVEEDOR NUMBER,
PRIMARY KEY(ID_PRODUCTO),
CONSTRAINT FK_PRODUCTO_PROVEEDOR FOREIGN KEY (CEDULA_JURIDICA_PROVEEDOR) REFERENCES TBL_PROVEEDOR(CEDULA_JURIDICA),
CONSTRAINT UQ_CODIGO_BARRAS UNIQUE (CODIGO_BARRAS)
);

-- SP para insertar productos
CREATE OR REPLACE PROCEDURE SP_INSERTAR_PRODUCTO(
P_ID_PRODUCTO TBL_INVENTARIO.ID_PRODUCTO%TYPE,
P_CODIGO_BARRAS TBL_INVENTARIO.CODIGO_BARRAS%TYPE,
P_NOMBRE_PRODUCTO TBL_INVENTARIO.NOMBRE_PRODUCTO%TYPE,
P_CATEGORIA TBL_INVENTARIO.CATEGORIA%TYPE,
P_COSTO TBL_INVENTARIO.COSTO%TYPE,
P_CANTIDAD TBL_INVENTARIO.CANTIDAD%TYPE,
P_CEDULA_JURIDICA_PROVEEDOR TBL_INVENTARIO.CEDULA_JURIDICA_PROVEEDOR%TYPE
) AS
 V_COUNT NUMBER;
BEGIN 
 SELECT COUNT(*)
 INTO V_COUNT
 FROM TBL_INVENTARIO
 WHERE ID_PRODUCTO = P_ID_PRODUCTO;
 
 IF V_COUNT > 0 THEN
 DBMS_OUTPUT.PUT_LINE('YA EXISTE UN REGISTRO CON EL ID ' || P_ID_PRODUCTO);
 ELSE 
 INSERT INTO TBL_INVENTARIO(ID_PRODUCTO,CODIGO_BARRAS,NOMBRE_PRODUCTO,CATEGORIA,COSTO,CANTIDAD,CEDULA_JURIDICA_PROVEEDOR)
 VALUES(P_ID_PRODUCTO,P_CODIGO_BARRAS,P_NOMBRE_PRODUCTO,P_CATEGORIA,P_COSTO,P_CANTIDAD,P_CEDULA_JURIDICA_PROVEEDOR);
 COMMIT;
 DBMS_OUTPUT.PUT_LINE('REGISTRO REALIZADO');
 END IF;
END;
/

-- SP para actualizar productos
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PRODUCTO(
P_ID_PRODUCTO TBL_INVENTARIO.ID_PRODUCTO%TYPE,
P_CODIGO_BARRAS TBL_INVENTARIO.CODIGO_BARRAS%TYPE,
P_NOMBRE_PRODUCTO TBL_INVENTARIO.NOMBRE_PRODUCTO%TYPE,
P_CATEGORIA TBL_INVENTARIO.CATEGORIA%TYPE,
P_COSTO TBL_INVENTARIO.COSTO%TYPE,
P_CANTIDAD TBL_INVENTARIO.CANTIDAD%TYPE,
P_ID_PROVEEDOR TBL_INVENTARIO.ID_PROVEEDOR%TYPE
) AS
 V_COUNT NUMBER;
BEGIN 
 SELECT COUNT(*)
 INTO V_COUNT
 FROM TBL_INVENTARIO
 WHERE ID_PRODUCTO = P_ID_PRODUCTO;
 
 IF V_COUNT > 0 THEN
 UPDATE TBL_INVENTARIO
 SET CODIGO_BARRAS = P_CODIGO_BARRAS,NOMBRE_PRODUCTO =P_NOMBRE_PRODUCTO, CATEGORIA =P_CATEGORIA, COSTO = P_COSTO, CANTIDAD = P_CANTIDAD, ID_PROVEEDOR = P_ID_PROVEEDOR
 WHERE ID_PRODUCTO = P_ID_PRODUCTO;
 COMMIT;
 DBMS_OUTPUT.PUT_LINE('REGISTRO ACTUALIZADO');
 ELSE 
 DBMS_OUTPUT.PUT_LINE('NO EXISTE PRODUCTO CON EL ID' || P_ID_PRODUCTO);
 END IF;
END;
/

-- SP para eliminar productos
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PRODUCTO(
P_CODIGO_BARRAS TBL_INVENTARIO.CODIGO_BARRAS%TYPE
) AS
 V_COUNT NUMBER;
BEGIN 
 SELECT COUNT(*)
 INTO V_COUNT
 FROM TBL_INVENTARIO
 WHERE CODIGO_BARRAS = P_CODIGO_BARRAS;

 IF V_COUNT > 0 THEN
 DELETE FROM TBL_INVENTARIO
 WHERE CODIGO_BARRAS = P_CODIGO_BARRAS;
 COMMIT;
 DBMS_OUTPUT.PUT_LINE('REGISTRO ELIMINADO');
 ELSE 
 DBMS_OUTPUT.PUT_LINE('NO EXISTE PRODUCTO CON EL ID' || P_ID_PRODUCTO);
 END IF;
END;
/

-- Inicia bloque de funciones

-- Buscar productos por codigo de barras, devuelve nombre
CREATE OR REPLACE FUNCTION CONSULTAR_INVENTARIO_POR_CODIGO(CODIGO_BARRAS_IN NUMBER)
RETURN VARCHAR2
IS
    NOMBRE_PRODUCTO TBL_INVENTARIO.NOMBRE_PRODUCTO%TYPE;
    NOMBRE_PROVEEDOR TBL_PROVEEDOR.NOMBRE%TYPE;
BEGIN
    -- Buscar el nombre del distrito en la tabla TBL_DISTRITO
    SELECT D.ID_DISTRITO, D.NOMBRE_DISTRITO
    INTO ID_DISTRITO, NOMBRE_DISTRITO
    FROM TBL_DISTRITO D
    WHERE ID_DISTRITO = ID_DISTRITO_IN;

    -- Retornar el resultado
    RETURN 'EL DISTRITO CON ID: ' || ID_DISTRITO || ' SE LLAMA: ' || NOMBRE_DISTRITO;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'EL DISTRITO CON ID: ' || ID_DISTRITO || ' NO FUE ENCONTRADO';
    WHEN OTHERS THEN
        RETURN 'ERROR AL CONSULTAR EL DISTRITO';
END;
/