/*
Crear un procedimiento para dar de alta un departamento, teniendo en cuenta que el mismo recibe por parametros el nombre y el id 
de localidad y devuelve por parametro en id de nuevo departamento creado.

a. Contemplar todos los errores posibles y nunca cancelar (es decir, validar las excepciones y mostrar mensajes de error llegado 
el caso, pero no utilizar Raise Exception error en este caso).

* Para generar el nuevo id, se le suma 1 al maximo existente en la tabla.
*/

CREATE OR REPLACE PROCEDURE alta_departamento(p_nombre IN DEPARTMENT.NAME%TYPE, p_id_localidad IN DEPARTMENT.LOCATION_ID%TYPE, p_id_departamento OUT DEPARTMENT.DEPARTMENT_ID%TYPE)
IS
    -- Excepcion por si el ID ingresado es muy largo.
    e_id_too_large EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_id_too_large, -01438);
BEGIN
    -- Obtengo el maximo ID y le sumo uno, que sera el nuevo ID
    SELECT MAX(DEPARTMENT_ID) + 1 INTO p_id_departamento
    FROM DEPARTMENT;

    -- Inserto el nuevo departamento
    INSERT INTO DEPARTMENT(DEPARTMENT_ID, NAME, LOCATION_ID)
    VALUES(p_id_departamento, p_nombre, p_id_localidad);
    DBMS_OUTPUT.PUT_LINE('El departamento se ha insertado correctamente');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('El ID del departamento ya existe');
    WHEN e_id_too_large THEN
        DBMS_OUTPUT.PUT_LINE('El ID del departamento es muy largo');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido');
END;

/*
Construir una función que recibe un salario y devuelve el valor del id de la escala de salarios.

a. Construir un bloque anónimo que liste todos los empleados que pertenecen a esa escala de salarios 
(utilizando la función creada en este punto).
*/

-- Funcion que retorna el id de la escala salarial correspondiente al salario pasado como parametro.
CREATE OR REPLACE FUNCTION obtener_escala_salario(p_salario EMPLOYEE.SALARY%TYPE)
RETURN NUMBER
IS
    id_rango SALARY_GRADE.GRADE_ID%TYPE;
BEGIN
    -- Obtengo el id del rango salarial y lo guardo en una variable.
    SELECT GRADE_ID INTO id_rango
    FROM SALARY_GRADE
    WHERE p_salario BETWEEN LOWER_BOUND AND UPPER_BOUND;

    RETURN id_rango;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'No existe un rango salarial para ese salario');
END;

-- Bloque anonimo que lista todos los empleados que pertenecen a ese rango salarial.
DECLARE
    v_salario EMPLOYEE.SALARY%TYPE := :salario;
    v_escala_salario SALARY_GRADE.GRADE_ID%TYPE := obtener_escala_salario(v_salario);

    CURSOR EMPLOYEE_CURSOR IS
         -- Obtengo el nombre de los empleados que estan dentro del rango salarial.
        SELECT E.FIRST_NAME, E.LAST_NAME
        FROM EMPLOYEE E
        JOIN SALARY_GRADE S ON E.SALARY BETWEEN S.LOWER_BOUND AND S.UPPER_BOUND
        WHERE v_escala_salario = S.GRADE_ID;
BEGIN
    FOR E_I IN EMPLOYEE_CURSOR LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || E_I.FIRST_NAME || ' Apellido: ' || E_I.LAST_NAME);
    END LOOP;
END;

/*
Escribir una función que recibe como parámetro un nombre de una función (function) y retorna su ID (job_id) o cancela 
con excepciones propias indicando el error en elmensaje del error.

a. Contemplar todo error posible.
*/

-- Funcion que retorna el id de la funcion pasada por parametro.
CREATE OR REPLACE FUNCTION get_function_id(p_nombre JOB.FUNCTION%TYPE)
RETURN NUMBER
IS
    v_function_id JOB.JOB_ID%TYPE;
BEGIN
    SELECT JOB_ID INTO v_function_id
    FROM JOB
    WHERE FUNCTION = p_nombre;

    RETURN v_function_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'No existe una funcion con ese nombre.');
END;

-- Bloque anonimo para probar la funcion.
DECLARE
    v_nombre JOB.FUNCTION%TYPE := :nombre;
BEGIN
    DBMS_OUTPUT.PUT_LINE('ID:' || get_function_id(v_nombre));
END;

-- Escribir un procedimiento que permite modificar la función de un empleado.
-- Procedimiento que recibe ID del empleado a modificar y el nombre de la nueva funcion que recibira.
CREATE OR REPLACE PROCEDURE modificar_funcion_empleado(p_id_empleado IN EMPLOYEE.EMPLOYEE_ID%TYPE, p_funcion IN JOB.FUNCTION%TYPE)
IS
    -- Obtengo el id de la funcion pasada por parametro.
    v_id_funcion JOB.JOB_ID%TYPE := get_function_id(p_funcion);
    -- Defino una excepcion por si no existe una funcion con ese nombre.
    e_no_data_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_data_found, -20001);
    e_no_employee_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_employee_found, -20002);
BEGIN
    UPDATE EMPLOYEE
    SET JOB_ID = v_id_funcion
    WHERE EMPLOYEE_ID = p_id_empleado;
    -- Controlo que se haya realizado el update.
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No existe un empleado con ese ID');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('El empleado se ha actualizado correctamente');
    END IF;
EXCEPTION
    WHEN e_no_employee_found THEN
        DBMS_OUTPUT.PUT_LINE('No existe un empleado con ese ID');
    WHEN e_no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('No existe una funcion con ese nombre.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido');
END;
