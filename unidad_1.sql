-- Consultar las tablas existentes en su cuenta, ver su estructura y contenido. (UsarVentana de Conexiones APEX-ORACLE 
SELECT *
FROM user_tables
-- Mostrar las distintas funciones (jobs) que pueden cumplir los empleados.
SELECT DISTINCT FUNCTION
FROM JOB
-- Desplegar el nombre completo de todos los empleados (Ej: Adam, Diane) ordenadospor apellido.
SELECT FIRST_NAME, LAST_NAME
FROM EMPLOYEE
ORDER BY LAST_NAME ASC
-- Mostrar el nombre y el apellido de los empleados que ganan entre $1500 y $2850.
SELECT FIRST_NAME, LAST_NAME, SALARY
FROM EMPLOYEE
WHERE SALARY BETWEEN 1500 AND 2850
-- Mostrar el nombre y la fecha de ingreso de todos los empleados que ingresaron en el año 2006.
SELECT FIRST_NAME, LAST_NAME, HIRE_DATE
FROM EMPLOYEE
WHERE HIRE_DATE BETWEEN '1-1-2006' AND '31-12-2006'
-- Mostrar el id y nombre de todos los departamentos de la localidad 122.
SELECT DEPARTMENT_ID, NAME
FROM DEPARTMENT
WHERE LOCATION_ID = 122
-- Modificar el ejercicio anterior para que la localidad pueda ser ingresada en elmomento de efectuar la consulta.
SELECT DEPARTMENT_ID, NAME
FROM DEPARTMENT
WHERE LOCATION_ID = :pp
-- Mostrar el nombre y salario de los empleados que no tienen jefe.
SELECT FIRST_NAME, SALARY
FROM EMPLOYEE
WHERE MANAGER_ID IS NULL
-- Mostrar el nombre de los empleados, su comisión y un cartel que diga  "Sin comisión" para aquellos empleados que tienen su comisión en nulo.
SELECT FIRST_NAME, LAST_NAME, NVL(TO_CHAR(COMMISSION), 'Sin Comision') COMISION
FROM EMPLOYEE
-- Mostrar el nombre completo de los empleados, el número de departamento y el nombre del departamento donde trabajan.
SELECT E.FIRST_NAME, E.LAST_NAME, E.DEPARTMENT_ID, D.NAME
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
-- Mostrar el nombre y apellido, la función que ejercen, el nombre del departamento yel salario de todos los empleados ordenados por su apellido.
SELECT E.FIRST_NAME, E.LAST_NAME, E.SALARY, J.FUNCTION, D.NAME
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN JOB J ON E.JOB_ID = J.JOB_ID
ORDER BY E.LAST_NAME
-- Para todos los empleados que cobran comisión, mostrar su nombre, el nombre del departamento donde trabajan y el nombre de la región a la que pertenece el departamento.
SELECT E.FIRST_NAME, D.NAME, L.REGIONAL_GROUP
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN LOCATION L ON D.LOCATION_ID = L.LOCATION_ID
WHERE E.COMMISSION IS NOT NULL
-- Para cada empleado mostrar su id, apellido, salario y grado de salario.
SELECT E.EMPLOYEE_ID, E.LAST_NAME, E.SALARY, G.GRADE_ID
FROM EMPLOYEE E
JOIN SALARY_GRADE G ON E.SALARY BETWEEN G.LOWER_BOUND AND G.UPPER_BOUND
-- Mostrar el número y nombre de cada empleado junto con el número de empleado y nombre de su jefe.
SELECT  E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME, E.MANAGER_ID, M.FIRST_NAME, M.LAST_NAME
FROM EMPLOYEE E
JOIN EMPLOYEE M ON E.MANAGER_ID = M.EMPLOYEE_ID
-- Modificar el ejercicio anterior para mostrar también aquellos empleados que notienen jefe.
SELECT  E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME, E.MANAGER_ID, M.FIRST_NAME, M.LAST_NAME
FROM EMPLOYEE E
LEFT JOIN EMPLOYEE M ON E.MANAGER_ID = M.EMPLOYEE_ID -- El left join nos permite obtener tambien aquellos empleados que no tienen un manager.
-- Mostrar las órdenes de venta, el nombre del cliente al que se vendió y la descripción de los productos. Ordenar la consulta por nro. de orden.
SELECT O.ORDER_ID, C.NAME, P.DESCRIPTION
FROM SALES_ORDER O
JOIN CUSTOMER C ON O.CUSTOMER_ID = C.CUSTOMER_ID
JOIN PRODUCT P ON P.PRODUCT_ID IN (
    SELECT I.PRODUCT_ID
    FROM ITEM I
    WHERE O.ORDER_ID = I.ORDER_ID
)
ORDER BY O.ORDER_ID
-- Mostrar la cantidad de clientes.
SELECT DISTINCT COUNT(CUSTOMER_ID)
FROM CUSTOMER
-- Mostrar la cantidad de clientes del estado de Nueva York (NY)
SELECT DISTINCT COUNT(CUSTOMER_ID)
FROM CUSTOMER
WHERE STATE = 'NY'
-- Mostrar la cantidad de empleados que son jefes. Nombrar a la columna 'JEFES'.
SELECT DISTINCT COUNT(EMPLOYEE_ID) JEFES
FROM EMPLOYEE
JOIN JOB J ON EMPLOYEE.JOB_ID = J.JOB_ID
WHERE J.FUNCTION IN ('MANAGER', 'PRESIDENT')
-- Mostrar toda la información del empleado más antiguo.
SELECT *
FROM EMPLOYEE
WHERE HIRE_DATE = (
    SELECT MIN(HIRE_DATE)
    FROM EMPLOYEE
)
-- Generar un listado con el nombre completo de los empleados, el salario, y el nombre de su departamento para todos los empleados que tengan el mismo cargo que John Smith. Ordenar la salida por salario y apellido.
SELECT E.FIRST_NAME, E.LAST_NAME, E.SALARY, D.NAME
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
WHERE E.JOB_ID = (
    SELECT JOB_ID
    FROM EMPLOYEE
    WHERE FIRST_NAME = 'John' AND LAST_NAME = 'Smith'
)
ORDER BY E.SALARY, E.LAST_NAME
-- Seleccionar los nombres completos, el nombre del departamento y el salario deaquellos empleados que ganan más que el promedio de salarios.