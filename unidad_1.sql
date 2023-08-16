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
