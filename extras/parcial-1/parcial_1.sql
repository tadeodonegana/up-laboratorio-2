-- Listar todos los departmanetos y regiones en los que haya mas de 2 empleados, indicando el nombre del departamento
-- el nombre de la region y la cantidad de empleados bajo la denominacion TOTAL EMPLEADOS. 
-- El listado debe quedar ordenado por los departamentos con mayor cantidad de empleados.
SELECT D.NAME, L.REGIONAL_GROUP, COUNT(E.EMPLOYEE_ID) AS TOTAL_EMPLEADOS
FROM EMPLOYEE E
JOIN DEPARTMENT D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
JOIN LOCATION L ON L.LOCATION_ID = D.LOCATION_ID
GROUP BY D.NAME, L.REGIONAL_GROUP
HAVING COUNT(E.EMPLOYEE_ID) > 2
ORDER BY COUNT(E.EMPLOYEE_ID) DESC;

-- En la tabla JOB, agregar un nuevo puesto de trabajo: 100-Inspecciones,
-- Luego, asignar el puesto 100 a todos los empleados del departamento 30 que ganen menos de 1500 pesos.

--- Escribire un bloque anonimo para realizar esta tarea
BEGIN
    --- Utilizo un ID 999 por simplicidad, ya que no se especifica usar otro, ni sumarle 1 al maximo.
    INSERT INTO JOB(JOB_ID, FUNCTION)
    VALUES (999, '100-Inspecciones');

    --- Actualizo los sueldos
    UPDATE EMPLOYEE
    SET JOB_ID = 999
    WHERE DEPARTMENT_ID = 30 AND SALARY < 1500;
END;

-- Escribir una funcion denominada CODIGO_LOCALIDAD que al recibir como parametro el nombre de una region (regional_group) retorne
-- su ID (location_id). Manejar las excepciones correspondientes, retornando:
-- 0 si la region no existe
-- -1 si existen varias regiones que se corresponden con el parametro ingresado
-- -2 para cualquier otro error que pueda ocurrir.

CREATE OR REPLACE FUNCTION CODIGO_LOCALIDAD(p_regional_group VARCHAR2)
RETURN NUMBER 
IS v_location_id LOCATION.LOCATION_ID%TYPE;
BEGIN
    SELECT LOCATION_ID INTO v_location_id
    FROM LOCATION 
    WHERE REGIONAL_GROUP = p_regional_group;

    RETURN v_location_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN -- Si la region no existe
        RETURN 0;
    WHEN TOO_MANY_ROWS THEN -- Varias regiones
        RETURN -1;
    WHEN OTHERS THEN -- Otros errores
        RETURN -2;
END;

-- Hago un bloque anomino para probar la funcion
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE(CODIGO_LOCALIDAD('BOSTON'));
END;

-- Escribir un procedimiento ELIMINAR_DEPTO que permita eliminar todos los departamentos ubicados en una localidad (regional_group).
-- El procedimiento recibe como parametro el nombre de la region y obtiene su id de localidad (location_id) utilizando la funcion
-- definida en el punto 2.
-- Manejar los mensaje y las excepciones correspondientes al procedimiento a saber:
-- Debe imprimir DEPARTAMENTO ELIMINADO u OCURRIO UN PROBLEMA AL BORRAR LOS DEPAPRTAMENTOS DE LA LOCALIDAD.

CREATE OR REPLACE PROCEDURE ELIMINAR_DEPTO(p_regional_group LOCATION.REGIONAL_GROUP%TYPE)
IS 
    v_location_id LOCATION.LOCATION_ID%TYPE;
    e_restriccion_integridad EXCEPTION;
    -- Es necesario definir esta excepcion ya que no se puede eliminar un departamento por restriccion de integridad.
    PRAGMA EXCEPTION_INIT(e_restriccion_integridad, -02292);
BEGIN
    v_location_id := CODIGO_LOCALIDAD(p_regional_group);
    
    -- Lo manejo de esta forma ya que el ejercicio anterior retornaba valores, y no permitia el uso de RAISE_APPLICATION_ERROR
    -- para retornar un error.
    IF v_location_id NOT IN (0, -1, -2) THEN
        DELETE * 
        FROM DEPARTMENT
        WHERE LOCATION_ID = v_location_id;
        -- Verifico si la operacion se realizo correctamente usando el cursos implicito SQL%ROWCOUNT
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('DEPARTAMENTO ELIMINADO');
        ELSE
            DBMS_OUTPUT.PUT_LINE('OCURRIO UN PROBLEMA AL BORRAR LOS DEPARTAMENTOS DE LA LOCALIDAD');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('OCURRIO UN PROBLEMA AL BORRAR LOS DEPARTAMENTOS DE LA LOCALIDAD');
    END IF;
EXCEPTION
    WHEN e_restriccion_integridad THEN
        DBMS_OUTPUT.PUT_LINE('OCURRIO UN PROBLEMA AL BORRAR LOS DEPARTAMENTOS DE LA LOCALIDAD');
END;

-- Escribir un bloque anonimo que permita ingresar como variable de sustitucion un codigo de departamento y liste para ese
-- departamento el apellido de todos sus empleados junto con el apellido de su jefe y el salario de ambos ordenados por apellido
-- del jefe. (Recordar que la variable de sustitucion lleva dos puntos adelante).
DECLARE
    v_department_id DEPARTMENT.DEPARTMENT_ID%TYPE := :cod_departamento;
    CURSOR DATOS_EMPLEADOS IS
        SELECT E.LAST_NAME AS e_last, E.SALARY AS e_salary, E2.LAST_NAME AS m_last, E2.SALARY AS m_salary
        FROM EMPLOYEE E
        JOIN EMPLOYEE E2 ON E.MANAGER_ID = E2.EMPLOYEE_ID
        WHERE E.DEPARTMENT_ID = v_department_id
        ORDER BY E2.LAST_NAME;
BEGIN
    FOR E IN DATOS_EMPLEADOS LOOP
        DBMS_OUTPUT.PUT_LINE('EMPLEADO: ' || E.e_last || E.e_salary || ' MANAGER: ' || E.m_last || E.m_salary);
    END LOOP;  
END;