/*
1.1 - Escribir una función que recibe como parámetro un nombre de una región (regional _group) y retorna su ID (location_id) o cancela con excepciones propias indicando el error en el mensaje del
error. Contemplar todo error posible.

1.2 - Escribir un procedimiento que permita incrementar un 50% el sueldo a todos los empleados que trabajan en los departamentos que se encuentran en una localidad.
El procedimiento recibe como parámetro el nombre de la localidad y obtiene su ID utilizando la función del punto 1,1
Manejar las excepciones correspondientes.
• Informar si el procedimiento pudo realizar su propósito correctamente
• Si no se pudo realizar se debe informar el motivo. No Cancelar.
*/

-- 1.1
CREATE OR REPLACE FUNCTION GET_LOCATION_ID(p_in_regional_group IN LOCATION.REGIONAL_GROUP%TYPE)
RETURN LOCATION.LOCATION_ID%TYPE
IS
    v_location_id LOCATION.LOCATION_ID%TYPE;
BEGIN
    SELECT LOCATION_ID INTO v_location_id
    FROM LOCATION
    WHERE REGIONAL_GROUP = p_in_regional_group;

    RETURN v_location_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, 'No existe location_id para el regional_group ingresado');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Existe mas de un location_id para el regional_group ingresado');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error en la funcion GET_LOCATION_ID');
END;
-- Bloque anonimo para probar
DECLARE
    LOCATION_ID LOCATION.LOCATION_ID%TYPE := GET_LOCATION_ID('DALLAsS');
BEGIN
    DBMS_OUTPUT.PUT_LINE(LOCATION_ID);
END;

-- 1.2

CREATE OR REPLACE PROCEDURE AUMENTAR_SUELDO(p_in_regional_group IN LOCATION.REGIONAL_GROUP%TYPE)
IS
    v_location_id LOCATION.LOCATION_ID%TYPE := GET_LOCATION_ID(p_in_regional_group);
    -- Defino excepciones
    e_no_location_id EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_location_id, -20000);
    e_too_many_location_id EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_too_many_location_id, -20001);
    e_get_location_other_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_get_location_other_error, -20002);
BEGIN
    UPDATE EMPLOYEE
    SET SALARY = SALARY * 1.5
    WHERE DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM DEPARTMENT WHERE LOCATION_ID = v_location_id);
    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Se ha incrementado el sueldo correctamente');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se ha podido incrementar el sueldo');
    END IF;
EXCEPTION
    WHEN e_no_location_id THEN
        DBMS_OUTPUT.PUT_LINE('No existe location_id para el regional_group ingresado');
    WHEN e_too_many_location_id THEN
        DBMS_OUTPUT.PUT_LINE('Existe mas de un location_id para el regional_group ingresado');
    WHEN e_get_location_other_error THEN
        DBMS_OUTPUT.PUT_LINE('Error en la funcion GET_LOCATION_ID');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error desconocido');
END;
-- Bloque anonimo para probar
DECLARE
BEGIN
    AUMENTAR_SUELDO('BOSTON');
END;

/*
Crear un paquete INGRESO_PERSONAL para el ingreso de nuevos empleados, el mismo debe contener:
- Una función privada VALIDA_DEPARTAMENTO_LOCALIDAD (department_id, location_id) para validar si existe o no, un departamento en una localidad. Manejar las excepciones correspondientes
- Una función privada JEFE para obtener el id del jefe del departamento en el cual va a ingresar el empleado.
Si el departamento tiene más de un jefe, retornar el ID del primer departamento que encuentra. Manejar las excepciones correspondientes.
- Un procedimiento público: ALTA_EMPLEADO que recibe como parámetros:
- ID del nuevo empleado
- nombre del nuevo empleado 
- apellido del nuevo empleado
- el ID de la tarea (JOB) que realizará el nuevo empleado 
- el ID del departamento al que ingresa el nuevo empleado 
- el ID de la localidad a la que ingresa el nuevo empleado
El paquete debe:
a. Utilizar la función JEFE para asignar el MANAGER al nuevo empleado.
b. La fecha de ingreso es igual a la fecha del día de ejecución del package
C. El salario inicial es igual al promedio del salario de los empleados pertenecientes al departamento de ingreso bajo el mismo jefe.
d. Utilizar la función VALIDA_DEPARTAMENTO_LOCALIDAD para verificar que el departamento al que ingresa el empleado exista dentro de la localidad también ingresada como parámetro. Si el departamento no existe, no puede realizarse el ingreso y se debe informar el motivo. No cancelar
e. Las columnas no mencionadas quedan en NULL.
*/

-- Especificicacion
CREATE OR REPLACE PACKAGE INGRESO_PERSONAL AS
    PROCEDURE ALTA_EMPLEADO(p_in_employee_id IN EMPLOYEE.EMPLOYEE_ID%TYPE, p_in_first_name IN EMPLOYEE.FIRST_NAME%TYPE, p_in_last_name IN EMPLOYEE.LAST_NAME%TYPE, p_in_job_id IN EMPLOYEE.JOB_ID%TYPE, p_in_department_id IN EMPLOYEE.DEPARTMENT_ID%TYPE, p_in_location_id IN EMPLOYEE.DEPARTMENT_ID%TYPE);
END INGRESO_PERSONAL;

-- Body
CREATE OR REPLACE PACKAGE BODY INGRESO_PERSONAL IS

    -- Una función privada VALIDA_DEPARTAMENTO_LOCALIDAD(department_id, location_id) para validar si existe o no, un departamento en una localidad.
    FUNCTION VALIDA_DEPARTAMENTO_LOCALIDAD(p_in_department_id IN DEPARTMENT.DEPARTMENT_ID%TYPE, p_in_location_id IN DEPARTMENT.LOCATION_ID%TYPE)
    RETURN BOOLEAN
    IS
        v_count NUMBER;
    BEGIN
        -- La logica detras es contar cuantos departamentos hay con el id y la localidad ingresada. Si hay mas de 0 entonces existe.
        SELECT COUNT(*)
        INTO v_count
        FROM DEPARTMENT
        WHERE DEPARTMENT_ID = p_in_department_id AND LOCATION_ID = p_in_location_id;
        IF v_count > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Error en la funcion VALIDA_DEPARTAMENTO_LOCALIDAD');
    END VALIDA_DEPARTAMENTO_LOCALIDAD;

    -- Una función privada JEFE para obtener el id del jefe del departamento en el cual va a ingresar el empleado.
    FUNCTION JEFE(p_in_department_id IN DEPARTMENT.DEPARTMENT_ID%TYPE)
    RETURN EMPLOYEE.EMPLOYEE_ID%TYPE
    IS
        manager_id EMPLOYEE.EMPLOYEE_ID%TYPE;
    BEGIN
        -- Obtengo el ID del jefe devolviendo el minimo, ya que en cada departamento corresponde al jefe
        SELECT MIN(MANAGER_ID) INTO manager_id
        FROM EMPLOYEE
        WHERE DEPARTMENT_ID = p_in_department_id;
        RETURN manager_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe el departamento ingresado');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error en la funcion JEFE');
    END JEFE;

    -- ALTA_EMPLEADO
    PROCEDURE ALTA_EMPLEADO(p_in_employee_id IN EMPLOYEE.EMPLOYEE_ID%TYPE, p_in_first_name IN EMPLOYEE.FIRST_NAME%TYPE, p_in_last_name IN EMPLOYEE.LAST_NAME%TYPE, p_in_job_id IN EMPLOYEE.JOB_ID%TYPE, p_in_department_id IN EMPLOYEE.DEPARTMENT_ID%TYPE, p_in_location_id IN EMPLOYEE.DEPARTMENT_ID%TYPE)
    IS
        v_manager_id EMPLOYEE.EMPLOYEE_ID%TYPE := JEFE(p_in_department_id);
        v_salary EMPLOYEE.SALARY%TYPE;
        -- Excepciones
        e_no_department EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_department, -20001);
        e_jefe_other_error EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_jefe_other_error, -20002);
        e_valida_department_localidad_other_error EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_valida_department_localidad_other_error, -20000);
    BEGIN
        -- Valido si existe el departamento en la localidad
        IF VALIDA_DEPARTAMENTO_LOCALIDAD(p_in_department_id, p_in_location_id) THEN
            -- Obtengo el nuevo salario a usar
            SELECT AVG(SALARY) INTO v_salary
            FROM EMPLOYEE
            WHERE DEPARTMENT_ID = p_in_department_id AND MANAGER_ID = v_manager_id;
            -- Inserto el nuevo empleado
            INSERT INTO EMPLOYEE(employee_id, last_name, first_name, middle_initial, job_id, hire_date, salary, commission, manager_id, department_id)
            VALUES(
                p_in_employee_id,
                p_in_last_name,
                p_in_first_name,
                NULL,
                p_in_job_id,
                SYSDATE,
                v_salary,
                NULL,
                v_manager_id,
                p_in_department_id
            );
            IF SQL%ROWCOUNT > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Se ha ingresado el empleado correctamente');
            ELSE
                -- Si por algun motivo no se actualizo ninguna fila cancelo
                RAISE_APPLICATION_ERROR(-20006, 'Ningun empleado fue insertado');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('El departamento no existe en la localidad. No se puede hacer el ingreso');
        END IF;
        EXCEPTION
            WHEN e_no_department THEN
                DBMS_OUTPUT.PUT_LINE('No existe el departamento ingresado');
            WHEN e_jefe_other_error THEN
                DBMS_OUTPUT.PUT_LINE('Error en la funcion JEFE');
            WHEN e_valida_department_localidad_other_error THEN
                DBMS_OUTPUT.PUT_LINE('Error en la funcion VALIDA_DEPARTAMENTO_LOCALIDAD');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error en el procedimiento ALTA_EMPLEADO');
    END ALTA_EMPLEADO;  
END INGRESO_PERSONAL;

-- Para probar ejecutar: INGRESO_PERSONAL.ALTA_EMPLEADO(7955, 'TADEO', 'DONEGANA', 670, 23, 124);
-- Para que ejecute bien primero hago ejecuto la especificacion y luego el body.