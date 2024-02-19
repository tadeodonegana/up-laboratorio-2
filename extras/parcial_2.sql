/*
Crear un paquete PERSONAL para dar de alta_empleados, el mismo debe contener:

- Una variable publica id_dept con el mismo tipo de dato que la columna department_id de la tabla department.

­- Una función privada OBTENER_DEPARTAMENTO(location_id) para obtener el mínimo código de departamento (department_id) al que corresponde una localidad 
y lo guarde en la variable pública id_dept. Si la función falla el nuevo empleado ingresará al departamento 10 y se debe notificar que la localidad no existe.

­- Una función privada Obtener_MANAGER para obtener el id del jefe del departamento en el cual va a ingresar el empleado.
Si el departamento tiene más de un jefe, retornar el primer departamento que encuentra.

- Una función pública MAXIMO_ID que retorne el máximo employee_id de todos los empleados

­- Un procedimiento público: alta_empleado que recibe como parámetros
first_name, last_name, job_id, location_id, salary

- Este procedimiento debe usar: 

    a. La funcion OBTENER_DEPARTAMENTO para determinar el departamento al cual va a ingresar el empleador de acuerdo con el parámetro location_id

    b. La función OBTENER_MANAGER para asignar el MANAGER al nuevo empleado.

    c. La fecha del día para asignar a la columna Hire_date.

    d. La comisión para el nuevo empleador equivale al 20% del salario que recibirá el nuevo empleado.

    e. El id del nuevo empleado es igual al valor que retorna la función MAXIMO_ID más uno.

    f. Las columnas no mencionadas se completan con NULL.

    g. Los datos first_name y last_name se graban en mayúsculas.
*/

-- Especificacion
CREATE OR REPLACE PACKAGE PERSONAL AS
    -- Declaracion de elementos publicos
    id_dept DEPARTMENT.DEPARTMENT_ID%TYPE;
    FUNCTION MAXIMO_ID RETURN EMPLOYEE.EMPLOYEE_ID%TYPE;
    PROCEDURE ALTA_EMPLEADO(first_name IN EMPLOYEE.FIRST_NAME%TYPE, last_name IN EMPLOYEE.LAST_NAME%TYPE, job_id IN EMPLOYEE.JOB_ID%TYPE, location_id IN EMPLOYEE.DEPARTMENT_ID%TYPE, salary IN EMPLOYEE.SALARY%TYPE);
END PERSONAL;

-- Body
CREATE OR REPLACE PACKAGE BODY PERSONAL IS
    -- Una función privada OBTENER_DEPARTAMENTO(location_id) para obtener el mínimo código de departamento (department_id) al que corresponde una localidad 
    -- y lo guarde en la variable pública id_dept. Si la función falla el nuevo empleado ingresará al departamento 10 y se debe notificar que la localidad no existe.
    FUNCTION OBTENER_DEPARTAMENTO(location_id IN LOCATION.LOCATION_ID%TYPE)
    RETURN DEPARTMENT.DEPARTMENT_ID%TYPE 
    IS
        dept_id DEPARTMENT.DEPARTMENT_ID%TYPE;
    BEGIN
    SELECT MIN(DEPARTMENT_ID) INTO dept_id
    FROM DEPARTMENT
    WHERE LOCATION_ID = location_id;

    IF SQL%ROWCOUNT > 0 THEN
        -- Asigno el resultado a la variable publica y tambien retorno el resultado
        id_dept := dept_id;
    ELSE
        id_dept := 10;
        -- No hago un RAISE_APPLICATION_ERROR por que no quiero cancelar, si pasa algo debo asignarle el 10 y seguir. Entonces solo imprimo
        DBMS_OUTPUT.PUT_LINE('La localidad no existe');
    END IF;
    
    RETURN id_dept;
    
    EXCEPTION
        -- Si hay otro error si que cancelo.
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en la funcion OBTENER_DEPARTAMENTO');
    END OBTENER_DEPARTAMENTO;

    -- Una función privada Obtener_MANAGER para obtener el id del jefe del departamento en el cual va a ingresar el empleado.
    -- Si el departamento tiene más de un jefe, retornar el primer manager id que encuentra.
    FUNCTION OBTENER_MANAGER
    RETURN EMPLOYEE.EMPLOYEE_ID%TYPE
    IS
        manager_id EMPLOYEE.EMPLOYEE_ID%TYPE;
    BEGIN
        -- Obtengo el ID del manager devolviendo el minimo, ya que en cada departamento corresponde al manager
        SELECT MIN(MANAGER_ID) INTO manager_id
        FROM EMPLOYEE
        WHERE DEPARTMENT_ID = id_dept;
        
        IF SQL%ROWCOUNT > 0 THEN
            RETURN manager_id;
        ELSE
            -- Si no hay manager hago un RAISE_APPLICATION_ERROR
            RAISE_APPLICATION_ERROR(-20001, 'No hay manager en el departamento');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en la funcion OBTENER_MANAGER');
    END OBTENER_MANAGER;

    -- Una función pública MAXIMO_ID que retorne el máximo employee_id de todos los empleados
    FUNCTION MAXIMO_ID
    RETURN EMPLOYEE.EMPLOYEE_ID%TYPE
    IS
        max_id EMPLOYEE.EMPLOYEE_ID%TYPE;
    BEGIN
        SELECT MAX(EMPLOYEE_ID) INTO max_id
        FROM EMPLOYEE;
        RETURN max_id;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en la funcion MAXIMO_ID');
    END MAXIMO_ID;

    -- Un procedimiento público: alta_empleado que recibe como parámetros
    -- first_name, last_name, job_id, location_id, salary
    PROCEDURE ALTA_EMPLEADO(first_name IN EMPLOYEE.FIRST_NAME%TYPE, last_name IN EMPLOYEE.LAST_NAME%TYPE, job_id IN EMPLOYEE.JOB_ID%TYPE, location_id IN EMPLOYEE.DEPARTMENT_ID%TYPE, salary IN EMPLOYEE.SALARY%TYPE)
    IS
        new_department_id DEPARTMENT.DEPARTMENT_ID%TYPE;
        new_manager_id EMPLOYEE.EMPLOYEE_ID%TYPE;
        new_employee_id EMPLOYEE.EMPLOYEE_ID%TYPE;

        e_no_manager EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_manager, -20001);
    BEGIN
        new_department_id := OBTENER_DEPARTAMENTO(location_id);
        new_manager_id := OBTENER_MANAGER;
        -- Le sumo 1 para poder insertar
        new_employee_id := MAXIMO_ID + 1;
        INSERT INTO EMPLOYEE(employee_id, last_name, first_name, middle_initial, job_id, hire_date, salary, commission, manager_id, department_id)
        VALUES(
            new_employee_id,
            UPPER(last_name),
            UPPER(first_name),
            NULL,
            job_id,
            SYSDATE,
            salary,
            salary * 0.2, -- Debo actualizar aca o para el empleador? Me quedo esa duda.
            new_manager_id,
            new_department_id
        );
        IF SQL%ROWCOUNT <= 0 THEN
            -- Si por algun motivo no se actualizo ninguna fila cancelo
            RAISE_APPLICATION_ERROR(-20006, 'Ningun empleado fue insertado');
        END IF;
    EXCEPTION
        WHEN e_no_manager THEN
            DBMS_OUTPUT.PUT_LINE('No hay manager en el departamento solicitado');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en el procedimiento ALTA_EMPLEADO');
    END ALTA_EMPLEADO;
END PERSONAL;

-- Para probar ejecutar: PERSONAL.ALTA_EMPLEADO('TADEO', 'DONEGANA', 670, 70, 500);
-- Para que ejecute bien primero hago ejecuto la especificacion y luego el body.