-- Determinar si estas declaraciones son correctas: 
--- V_var number(8,3); -> Correcta.
--- V_a, V-b number; -> Incorrecta.
--- V_fec_ingreso Date := sysdate +2; -> Correcta.
--- V_nombre varchar2(30) not null; -> Incorrecta.
--- V_logico boolean default ‘TRUE’; -> Incorrecta.

-- Crear un bloque anónimo para desplegar los siguientes mensajes:
-- ‘Hola , soy ‘ username‘ Hoy es: ‘ dd – Mon – yyyy’. (mostrar la fecha del día)
DECLARE
    V_username VARCHAR2(30);
    V_fecha DATE;
BEGIN
    V_username := :username;
    V_fecha := SYSDATE;
    DBMS_OUTPUT.PUT_LINE('Hola, soy ' || V_username || ' Hoy es: ' || TO_CHAR(V_fecha, 'DD-MON-YYYY'));
END;

-- Crear un bloque anónimo para desplegar los primeros n números múltiplos de 3.
-- El valor de n debe ingresarse por pantalla usando una variable de sustitución del SqlDeveloper. 
-- Si n >10 desplegar un mensaje de advertencia y terminar el bloque.
DECLARE
    V_n NUMBER := n;
    V_i NUMBER := 1;
BEGIN
    IF V_n > 10 THEN
        DBMS_OUTPUT.PUT_LINE('El valor de n no puede ser mayor a 10');
    ELSE
        WHILE V_i <= V_n LOOP
            DBMS_OUTPUT.PUT_LINE(V_i * 3);
            V_i := V_i + 1;
        END LOOP;
    END IF;
END;
-- Crear un bloque Pl/Sql para consultar el salario de un empleado dado: 
-- Ingresar el id del empleado usando una variable de sustitución 
-- Desplegar por pantalla el siguiente texto: First_name, Last_name tiene un salario de Salary pesos.
DECLARE
    V_id EMPLOYEE.EMPLOYEE_ID%TYPE := :id;
    V_first_name EMPLOYEE.FIRST_NAME%TYPE;
    V_last_name EMPLOYEE.LAST_NAME%TYPE;
    V_salary EMPLOYEE.SALARY%TYPE;
BEGIN
    SELECT FIRST_NAME, LAST_NAME, SALARY
    INTO V_first_name, V_last_name, V_salary
    FROM EMPLOYEE
    WHERE EMPLOYEE_ID = V_id;
    DBMS_OUTPUT.PUT_LINE(V_first_name || ', ' || V_last_name || ' tiene un salario de ' || V_salary || ' pesos.');
END;
-- Escribir un bloque para desplegar todos los datos de una orden dada. 
-- Ingresar el nro de orden usando una variable de sustitución. 
-- En una variable de tipo record recuperar toda la información y desplegarla usando Dbms_output.
-- Que pasa si la orden no existe?
--- Si la orden no existe lo manejo con la excepcion NO_DATA_FOUND.
DECLARE
    V_order_id SALES_ORDER.ORDER_ID%TYPE := :order_id;
    V_order SALES_ORDER%ROWTYPE;
BEGIN
    SELECT *
    INTO V_order
    FROM SALES_ORDER
    WHERE ORDER_ID = V_order_id;
    DBMS_OUTPUT.PUT_LINE(V_order.ORDER_ID || ', ' || V_order.ORDER_DATE || ', ' || V_order.CUSTOMER_ID || ', ' || V_order.SHIP_DATE || ', ' || V_order.TOTAL);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe la orden con ID: ' || V_order_id);
END;
-- Escribir un bloque para mostrar la cantidad de órdenes que emitió un cliente dado siguiendo las siguientes consignas:
-- Ingresar el id del cliente una variable de sustitución
-- Si el cliente emitió menos de 3 órdenes desplegar:
-- “El cliente nombre ES REGULAR”.
-- Si emitió entre 4 y 6“
-- El cliente nombre ES BUENO”.
-- Si emitió más:
-- “El cliente nombre ES MUY BUENO”
DECLARE
    V_customer_id CUSTOMER.CUSTOMER_ID%TYPE := :customer_id;
    V_count NUMBER;
BEGIN
    SELECT COUNT(ORDER_ID) INTO V_count
    FROM SALES_ORDER
    WHERE CUSTOMER_ID = V_customer_id;
    
    IF V_count <= 3 THEN
        BEGIN
            DBMS_OUTPUT.PUT_LINE('ES REGULAR');
        END;
    ELSIF V_count BETWEEN 4 AND 6 THEN
        BEGIN
            DBMS_OUTPUT.PUT_LINE('ES BUENO');
        END;
    ELSE
        BEGIN
            DBMS_OUTPUT.PUT_LINE('ES MUY BUENO');
        END;
    END IF;
END;

-- Ingresar un número de departamento n y mostrar el nombre del departamento y la cantidad de empleados que trabajan en él.
-- Si no tiene empleados sacar un mensaje “Sin empleados” 
-- Si tiene entre 1 y 10 empleados desplegar “Normal”
-- Si tiene más de 10 empleados, desplegar “Muchos”
DECLARE
    V_department_id DEPARTMENT.DEPARTMENT_ID%TYPE := :department_id;
    V_department_name DEPARTMENT.NAME%TYPE;
    V_count NUMBER;
BEGIN
    SELECT D.NAME, COUNT(E.EMPLOYEE_ID) INTO V_department_name, V_count
    FROM DEPARTMENT D
    JOIN EMPLOYEE E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
    WHERE D.DEPARTMENT_ID = V_department_id
    GROUP BY D.NAME;
    
    IF V_count = 0 THEN
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Sin Empleados');
        END;
    ELSIF V_count BETWEEN 1 AND 10 THEN
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Normal');
        END;
    ELSE
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Muchos');
        END;
    END IF;
END;
-- Crear un bloque que pida un número de empleado y muestre su apellido y nombre y tantos ‘*’ como resulte de dividir su salario por 100.
DECLARE
    V_employee_id EMPLOYEE.EMPLOYEE_ID%TYPE := :employee_id;
    V_first_name EMPLOYEE.FIRST_NAME%TYPE;
    V_last_name EMPLOYEE.LAST_NAME%TYPE;
    V_salary EMPLOYEE.SALARY%TYPE;
    V_count NUMBER;
BEGIN
    SELECT FIRST_NAME, LAST_NAME, SALARY INTO V_first_name, V_last_name, V_salary
    FROM EMPLOYEE
    WHERE EMPLOYEE_ID = V_employee_id;
    
    V_count := V_salary / 100;
    
    DBMS_OUTPUT.PUT_LINE(V_first_name || ' ' || V_last_name || ' ' || RPAD('*', V_count, '*'));
END;
-- Hacer un bloque que guarde en las posiciones pares de una tabla en memoria (tabla Pl/Sql) de números enteros el múltiplo de 2 de la posición. 
-- Ejemplo: T(4) := 8. Ingresar la cantidad de elementos que debe tener la tabla. Por último desplegar la cantidad de elementos que tiene la tabla y todo su contenido.
DECLARE
    TYPE T_tabla IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    V_tabla T_tabla;
    V_n NUMBER := :n;
BEGIN  
    FOR i IN 1..V_n LOOP
        V_tabla(i) := i * 2;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Cantidad de elementos: ' || V_tabla.COUNT);
    
    FOR i IN 1..V_tabla.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(V_tabla(i));
    END LOOP;
END;