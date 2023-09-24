/*
Desarrollar un bloque anonimo que imprima el nombre del departamento cuyo ID es igual a 10, 
teniendo en cuentas las posibles excepciones que dicha consulta pueda conllevar
*/

DECLARE
    v_nombre_departamento VARCHAR2(30);
BEGIN
    SELECT NAME INTO v_nombre_departamento
    FROM DEPARTMENT
    WHERE DEPARTMENT_ID = 10;
    DBMS_OUTPUT.PUT_LINE('El nombre del departamento es: ' || v_nombre_departamento);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe un departamento con ese ID');
    -- El too_many_rows nunca deberia ocurrir ya que no puede haber dos id duplicados.
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Hay mas de un departamento con ese ID');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido');
END;

/*
Desarrollar un bloque anonimo que lleve a cabo la inserción de un nuevo producto en la tabla de productos, 
teniendo en cuenta las posibles excepciones que dicha instrucción DML (en este caso un INSERT) pueda conllevar.
*/
DECLARE
    v_product_id NUMBER := :id;
    v_name VARCHAR2(30) := :name;
    e_id_too_large EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_id_too_large, -01438);
BEGIN
    INSERT INTO PRODUCT(PRODUCT_ID, DESCRIPTION)
    VALUES(v_product_id, v_name);
    DBMS_OUTPUT.PUT_LINE('El producto se ha insertado correctamente');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('El ID del producto ya existe');
    WHEN e_id_too_large THEN
        DBMS_OUTPUT.PUT_LINE('El ID del producto es muy largo');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido');
END;

/*
Desarrollar un bloque anonimo que devuelva e imprima el id de un empleado a partir de su nombre y apellido. 
Definir todas las excepciones que sean necesarias.
*/

DECLARE
    v_nombre EMPLOYEE.FIRST_NAME%TYPE := :nombre;
    v_apellido EMPLOYEE.LAST_NAME%TYPE := :apellido;
    v_id EMPLOYEE.EMPLOYEE_ID%TYPE;
BEGIN
    SELECT EMPLOYEE_ID INTO v_id
    FROM EMPLOYEE
    WHERE FIRST_NAME = v_nombre AND LAST_NAME = v_apellido;
    DBMS_OUTPUT.PUT_LINE('El ID del empleado es: ' || v_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe un empleado con ese nombre y apellido');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Hay mas de un empleado con ese nombre y apellido');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido');
END;

/*
Desarrollar un bloque anonimo que permita imprimir el nombre y apellido de un empleado según su id. 
Crear una excepción definida por el usuario que permita evaluar la posibilidad de que el id ingresado no cumpla con las 
condiciones de tipo de valor definidas para esa columna en la tabla de empleados (usar pragma).
*/

DECLARE
    v_id EMPLOYEE.EMPLOYEE_ID%TYPE := :id;
    v_nombre EMPLOYEE.FIRST_NAME%TYPE;
    v_apellido EMPLOYEE.LAST_NAME%TYPE;

    e_tipo_dato_invalido EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tipo_dato_invalido, -06502);
BEGIN
    SELECT E.FIRST_NAME, E.LAST_NAME INTO v_nombre, v_apellido
    FROM EMPLOYEE E
    WHERE E.EMPLOYEE_ID = v_id;
    DBMS_OUTPUT.PUT_LINE('El nombre del empleado es: ' || v_nombre || ' ' || v_apellido);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe un empleado con ese ID');
    WHEN e_tipo_dato_invalido THEN
        DBMS_OUTPUT.PUT_LINE('El tipo de dato del ID es incorrecto.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido');
END;

/*
Desarrollar un bloque anonimo que permita actualizar el nombre y apellido de un empleado según su id. 
Si el programa no encuentra ningún empleado con ese id, el programa debe cancelar por error 
(esto hace referencia a la asociación de la posibilidad de que el update no encuentre ningún empleado con un numero de 
error no standard)
*/
DECLARE
    v_id EMPLOYEE.EMPLOYEE_ID%TYPE := :id;
    v_nombre EMPLOYEE.FIRST_NAME%TYPE := :nombre;
    v_apellido EMPLOYEE.LAST_NAME%TYPE := :apellido;
BEGIN
    UPDATE EMPLOYEE
    SET FIRST_NAME = v_nombre, LAST_NAME = v_apellido
    WHERE EMPLOYEE_ID = v_id;
    -- Con el cursor implicito SQL%NOTFOUND verificamos si se devolvio o no alguna fila modificada.
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'No existe un empleado con ese ID');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('El empleado se ha actualizado correctamente');
    END IF;
END;

/*
Eliminar el departamento 10. Se puede? Por que?
    a. Desarrollar un bloque anonimo que permita contemplar dicha casuistica y cancele por error con un mensaje customizado 
    aclarando el por que del fallo.
*/

DECLARE
    e_integridad_violada EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_integridad_violada, -02292);
BEGIN
    DELETE FROM DEPARTMENT WHERE DEPARTMENT_ID=10;
EXCEPTION
    WHEN e_integridad_violada THEN
        DBMS_OUTPUT.PUT_LINE('Integridad violada.');
END;