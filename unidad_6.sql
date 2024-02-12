/*
1.- Construir un paquete PA_EMPLEADOS que contenga los siguientes objetos y resuelva las siguientes consignas:
a.- Una función que recibe como parámetros el nombre y apellido de un empleado, y retorna su id.
- Contemplar todas las excepciones posibles
b.- Un procedure que recibe el id de un empleado y a continuación incrementa su salario en un 10%
- Contemplar todas las excepciones posibles
- Mostrar un cartel con el nuevo salario del empleado
c.- Un procedure que recibe el id de un departamento y recorre con un cursor cada empleado de dicho departamento, incrementando su salario en un 10% (utilizar el procedure del punto b)
- Si el departamento no tiene empleados, el procedure debe cancelar con un error que indique “El departamento no tiene empleados” (Aca usar RAISE_APPLICATION_ERROR)
- Mostrar un cartel que indique cuantos empleados tenia el departamento
d.- Una función que recibe el id de un departamento y retorna el promedio de sueldos de dicho departamento.
*/
CREATE OR REPLACE PACKAGE BODY PA_EMPLEADOS IS
    -- Funcion que recibe como parametros el nombre y apellido de un empleado, y retorna su id.
    FUNCTION f_id_empleado(pi_nombre VARCHAR2, pi_apellido VARCHAR2) RETURN NUMBER IS
        v_id NUMBER;
    BEGIN
        SELECT employee_id INTO v_id
        FROM EMPLOYEE
        WHERE first_name = pi_nombre AND last_name = pi_apellido;
        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontro el empleado');
            RETURN 0;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Se encontro mas de un empleado');
            RETURN 0;
    END f_id_empleado;

    -- Procedure que recibe el id de un empleado y a continuacion incrementa su salario en un 10%
    PROCEDURE p_incrementa_salario(pi_employee_id NUMBER) IS
        v_salario NUMBER;
    BEGIN
        SELECT salary INTO v_salario
        FROM EMPLOYEE
        WHERE employee_id = pi_employee_id;
        
        UPDATE EMPLOYEE SET salary = salary + (salary * 0.1) WHERE employee_id = pi_employee_id;
        DBMS_OUTPUT.PUT_LINE('El nuevo salario del empleado es: ' || v_salario);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontro el empleado');
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Se encontro mas de un empleado');
    END p_incrementa_salario;

    -- Procedure que recibe el id de un departamento y recorre con un cursor cada empleado de dicho departamento, incrementando su salario en un 10% (utilizar el procedure del punto b)
    PROCEDURE p_incrementa_salario_dpto(pi_dpto_id NUMBER) IS
        v_cantidad_empleados NUMBER;
        v_salario NUMBER;
    BEGIN
        SELECT COUNT(employee_id) INTO v_cantidad_empleados
        FROM EMPLOYEE
        WHERE department_id = pi_dpto_id;
        IF v_cantidad_empleados = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El departamento no tiene empleados');
        END IF;
        FOR i IN (SELECT employee_id FROM EMPLOYEE WHERE department_id = pi_dpto_id) LOOP
            p_incrementa_salario(i.employee_id);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Cantidad de empleados del departamento:' || v_cantidad_empleados);

    -- Función que recibe el id de un departamento y retorna el promedio de sueldos de dicho departamento
    FUNCTION f_prom_salary(pi_dpto_id NUMBER) RETURN NUMBER IS
        v_promedio_salarios NUMBER;
    BEGIN
        SELECT AVG(salary) INTO v_promedio_salarios
        FROM EMPLOYEE
        WHERE department_id = pi_dpto_id;
        RETURN v_promedio_salarios;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'El departamento no existe');
    END f_prom_salary;
END PA_EMPLEADOS;