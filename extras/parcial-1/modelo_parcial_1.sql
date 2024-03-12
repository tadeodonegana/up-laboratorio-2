-- 1) Realice una consulta SQL que muestre el id de producto, descripción y cantidad de ordenes en las que fue vendido, para aquellos productos que estén 
--    en mas de 3 ordenes.  Ordenados por nombre de producto.
SELECT  I.PRODUCT_ID, P.DESCRIPTION, COUNT(I.ORDER_ID)
FROM ITEM I
JOIN PRODUCT P ON I.PRODUCT_ID = P.PRODUCT_ID
GROUP BY I.PRODUCT_ID, P.DESCRIPTION
HAVING COUNT(I.ORDER_ID) > 3

-- 2) Escribir una función que recibe como parámetro un nombre de producto y retorna su ID o cancela con excepciones propias indicando el error en el mensaje del error.
--    Contemplar todo error posible.
CREATE OR REPLACE
FUNCTION getID(p_name VARCHAR2)
RETURN NUMBER
IS 
    v_id NUMBER;
BEGIN
    SELECT P.PRODUCT_ID INTO v_id
    FROM PRODUCT P 
    WHERE P.DESCRIPTION = p_name;

    RETURN v_id;
EXCEPTION
    -- Si no hay un id para el producto ingresado
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'El producto ingresado no existe.');
END getID;

/* 3) Escribir un procedimiento que permite dar de alta un nuevo producto.

El procedimiento recibe como parámetro el nombre del producto y en nuevo id.

Validar que no haya en la base un producto con el mismo nombre utilizando la función anterior.

Manejar las excepciones correspondientes.

·  Informar si pudo realizar su propósito correctamente

·  Utilizar la función del punto anterior

·  Si no se pudo realizar informar el motivo correcto. No Cancelar 
*/
CREATE OR REPLACE PROCEDURE agregarProducto(pi_nombre VARCHAR2, pi_id NUMBER)
IS
    v_id NUMBER;
    e_no_data_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_data_found, -20003);
BEGIN
    -- Obtengo el id
    v_id := getID(pi_nombre);
    -- Si ya existe solo imprimo que existe, no cancelo.
    IF v_id IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('El producto ya existe.');
    END IF;

EXCEPTION
    -- Si el producto no existe lo agregamos
    WHEN e_no_data_found THEN
        INSERT INTO PRODUCT (PRODUCT_ID, DESCRIPTION)
        VALUES (pi_id, pi_nombre);
        DBMS_OUTPUT.PUT_LINE('Producto agregado correctamente.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido.' || SQLERRM);
END;

-- 4) Escribir un bloque anónimo que permita ingresar como variable de sustitución un código de producto y liste para este 
-- todo su historial de precios. Listar ordenados por fecha de vigencia.
-- ·   Si el producto no existe informarlo.
DECLARE
    v_cod_producto PRICE.PRODUCT_ID%TYPE := :cod_producto;
    CURSOR PRICE_CURSOR IS
        SELECT P.LIST_PRICE, P.START_DATE, P.END_DATE
        FROM PRICE P
        WHERE P.PRODUCT_ID = v_cod_producto
        ORDER BY P.END_DATE DESC;
    V_count NUMBER;
BEGIN
    FOR PRICE_REC IN PRICE_CURSOR LOOP
        V_count := V_count + 1;
        DBMS_OUTPUT.PUT_LINE('Precio: ' || PRICE_REC.LIST_PRICE || ' Fecha Inicio: ' || PRICE_REC.START_DATE || ' Fecha Fin: ' || PRICE_REC.END_DATE);
    END LOOP;
    IF V_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El producto no existe');
    END IF;
END;

-- Otra resolucion posible para no usar un IF en la seccion del cursor:
-- ...
OPEN historial;
    FETCH historial INTO test;
    IF historial%NOTFOUND
        THEN DBMS_OUTPUT.PUT_LINE ('No se encontró el producto!');
    END IF;
    CLOSE historial;
-- ...