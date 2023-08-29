-- Insertar un par de filas en la tabla JOB.
INSERT INTO JOB (JOB_ID, FUNCTION)
VALUES (673, 'ADVOCATE')

INSERT INTO JOB (JOB_ID, FUNCTION)
VALUES (674, 'ENGINEER')
-- Hacer COMMIT (COMMIT is the SQL command that is used for storing changes performed by a transaction. When a COMMIT command is issued it saves all the changes since last COMMIT or ROLLBACK.)
---- Recordar: Al usar APEX no es necesario usar COMMIT ya que se hace automaticamente.
DELETE from JOB where FUNCTION = 'ADVOCATE'
COMMIT;
-- Eliminar las filas insertadas en la tabla JOB.
DELETE from JOB where FUNCTION = 'ENGINEER'
-- Hacer ROLLBACK (ROLLBACK is the SQL command that is used for reverting changes performed by a transaction. When a ROLLBACK command is issued it reverts all the changes since last COMMIT or ROLLBACK.)
DELETE from JOB where FUNCTION = 'ADVOCATE'
ROLLBACK;
-- Seleccionar todas las filas de la tabla JOB.
SELECT * FROM JOB
-- Modificar el nombre de un cliente.
UPDATE CUSTOMER
SET NAME = 'JOCKSPORTS MODIFICADO'
WHERE CUSTOMER_ID = 100
-- Crear un SAVEPOINT A.
SAVEPOINT A;
-- Modificar el nombre de otro cliente
UPDATE CUSTOMER
SET NAME = 'JUST TENNIS MODIFICADO'
WHERE CUSTOMER_ID = 104
-- Crear un SAVEPOINT B.
SAVEPOINT B;
-- Hacer un ROLLBACK hasta el último SAVEPOINT creado.
ROLLBACK TO SAVEPOINT B;
-- Hacer un SELECT de toda la tabla CUSTOMER
SELECT * FROM CUSTOMER
-- Si quiero que la primera modificación del nombre de un cliente que hice quede asentada definitivamente en la base, debo hacer algo?.
---- Si, hacer un COMMIT.
-- Eliminar el departamento 10. Se puede? Por que?
---- No se puede, ya que hay empleados que pertenecen a ese departamento.
-- Insertar el departamento 50, ‘EDUCATION’ en la localidad 100. Se puede?
---- No se puede, ya que no existe la localidad 100. Arroja error: Restriccion de integridad. Clave principal no encontrada
-- Insertar el departamento 43, ‘OPERATIONS’ sin indicar la localidad. Se puede?
---- No se puede, ya que ya existe un departamento con el ID=43 (Sales). De todas manera si se usara otro ID se podria insertar ya que al no indicar la localidad queda como NULL ese campo y no hay problemas.
-- Modificar la localidad del departmento 20, para que pertenezca a la localidad 155. Se puede?
---- No se puede, ya que no existe la localidad 155. Arroja error: Restriccion de integridad. Clave principal no encontrada
-- Incrementar en un 10% el salario a todos los empleados que ganan menos que el promedio de salarios.
UPDATE EMPLOYEE
SET SALARY = SALARY * 1.1
WHERE SALARY < (
    SELECT AVG(SALARY)
    FROM EMPLOYEE
)
-- A todos los clientes que han generado más de 5 órdenes, incrementar su límite de crédito en un 5%.
UPDATE CUSTOMER
SET CREDIT_LIMIT = CREDIT_LIMIT * 1.05
WHERE CUSTOMER_ID IN (
    SELECT CUSTOMER_ID
    FROM SALES_ORDER
    GROUP BY CUSTOMER_ID
    HAVING COUNT(ORDER_ID) > 5
)
-- Deshacer todos estos cambios.
ROLLBACK;
-- Crear una tabla EMP2 con 4 columnas: id number(3), nombre varchar(10), salarionumber( no puede ser nulo) y depto number(2). Definir id como clave primaria,nombre debe ser único y depto debe referenciar a la tabla de Department.
CREATE TABLE EMP2 (
    ID NUMBER(3) PRIMARY KEY,
    NOMBRE VARCHAR(10) UNIQUE,
    SALARIO NUMBER NOT NULL,
    DEPTO NUMBER(2) REFERENCES DEPARTMENT(DEPARTMENT_ID)
)