-- Crear una funcion que permita sumar dos numeros.
CREATE OR REPLACE
FUNCTION sumaXY(p_x NUMBER, p_y NUMBER)
RETURN NUMBER
IS
    v_suma NUMBER;
BEGIN
    v_suma:= p_x + p_y;
    RETURN v_suma;
END sumaXY;

DECLARE
    v_suma NUMBER;
    v_numero1 NUMBER;
    v_numero2 NUMBER;
BEGIN
    v_numero1:= 120;
    v_numero2:= 85;
    v_suma:= sumaXY(v_numero1,v_numero2);
    DBMS_OUTPUT.PUT_LINE('El valor obtenido por la suma usando la funcion fue: ' || v_suma);
    DBMS_OUTPUT.PUT_LINE('El valor obtenido por la suma usando la funcion fue: ' || sumaXY(v_numero1,v_numero2));
END;
-- Crear una funcion que devuelva el promedio de salarios de un departamento especifico pasado por parametro.
CREATE OR REPLACE
FUNCTION f_prom_salary(p_id_dpto NUMBER)
RETURN NUMBER
IS
    v_promedio_salarios NUMBER;
BEGIN
    -- Obtengo el promedio de salario para un departamento especifico
    SELECT AVG(E.SALARY) INTO v_promedio_salarios
    FROM EMPLOYEE E
    WHERE E.department_id = p_id_dpto;
    RETURN v_promedio_salarios;
EXCEPTION
WHEN no_data_found THEN
    BEGIN
        -- La mejor practica aca seria ejecutar un raise application error.
        -- En este caso si se ejecuta devuelve 0, en vez de un codigo de error.
        DBMS_OUTPUT.PUT_LINE('El departamento no existe');
        RETURN 0;
    END;
END f_prom_salary;

-- Esto es un bloque anonimo, para probar la funcion.
DECLARE
    v_promedio_salarios NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('El promedio de sueldo del departamento 10 es: ' || round(f_prom_salary(10)));
END;

-- Creacion de un procedimiento con parametros de entrada y salida que permita obtener el promedio de salarios de un departamento y su numero de empleados
CREATE OR REPLACE 
PROCEDURE estadisticas_x_dpto(pi_dpto_id NUMBER, po_promedio_sal OUT NUMBER, po_cantidad_empleados OUT NUMBER)
IS
BEGIN
    SELECT AVG(salary), COUNT(employee_id)
    INTO po_promedio_sal, po_cantidad_empleados
    FROM EMPLOYEE
    WHERE department_id = pi_dpto_id;
END estadisticas_x_dpto;

-- Seccion de bloque anonimo para probar el procedimiento
DECLARE
    v_prom_salarios NUMBER;
    v_cantidad_empleados NUMBER;
BEGIN
    estadisticas_x_dpto(10, v_prom_salarios, v_cantidad_empleados);
    DBMS_OUTPUT.PUT_LINE('El promedio de salarios de los empleados fue: ' || v_prom_salarios);
    DBMS_OUTPUT.PUT_LINE('La cantidad de empleados del departamento 10 fue: ' || v_cantidad_empleados);
END;