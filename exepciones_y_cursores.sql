-- Ejercicio que combina cursores (explicitos e implicitos), junto a exepciones definidas por el usuario
DECLARE
CURSOR EMP_CURSOR IS -- Cursor Explicito
    SELECT EMPLOYEE_ID, LAST_NAME, FUNCTION, SALARY
    FROM EMPLOYEE E, JOB J
    WHERE E.JOB_ID = J.JOB_ID AND E.DEPARTMENT_ID = 909090;
E_SUELDOLIMITE EXCEPTION; -- Exepcion definida para el usuario, y manejada mas abajo.
PRAGMA EXCEPTION_INIT(E_SUELDOLIMITE, -01438);
BEGIN
FOR EMP_REC IN EMP_CURSOR LOOP
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Estamos iterando sobre el empleado: ' || EMP_REC.LAST_NAME);
        IF EMP_REC.FUNCTION = 'MANAGER' THEN
            DBMS_OUTPUT.PUT_LINE('El apellido del empleado al que le actualizaremos el sueldo por ser manager es: ' || EMP_REC.LAST_NAME);
            UPDATE EMPLOYEE SET SALARY = SALARY + 99999999999 WHERE EMPLOYEE_ID = EMP_REC.EMPLOYEE_ID; -- Aca tirara un error ya que el numero es mas grande de lo que acepta la columna
            DBMS_OUTPUT.PUT_LINE('La cantidad de filas que se actualizaron fueron: ' || sql%rowcount); -- El sql%rowcount es un cursor implicito
        END IF;
        EXCEPTION
        WHEN E_SUELDOLIMITE THEN
            DBMS_OUTPUT.PUT_LINE('El update fallo para el empleado: ' || EMP_REC.LAST_NAME);
        END;
    END LOOP;
END;