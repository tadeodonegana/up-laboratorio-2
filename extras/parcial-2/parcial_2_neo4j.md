## Pregunta
1.- Se necesita representar en una base de datos de tipo Grafos la siguiente situación:

Nos encontramos en una universidad, y necesitamos poder representar dentro del sistema a los estudiantes (para los cuales conocemos su Apellido, Nombre, Edad, DNI y nacionalidad), las materias que la universidad ofrece (para las cuales conocemos su Código, Descripción, Dia que se cursa, Profesor que la dicta y modalidad), y los profesores (para quienes conocemos su Apellido, Nombre, Antigüedad, Edad). 

Luego necesitamos representar como están relacionadas todas estas entidades entre si: Los estudiantes cursan materias, las materias son dictadas por profesores y los profesores pueden ser tutores de los alumnos.

Crear los nodos y las relaciones que permitan verificar:
El estudiante Sosa Ramiro de 20 años de edad, con DNI 33999888 cursa la materia Física cuya descripción es F190, y se cursa los Miércoles.
La materia Física (cuya modalidad es Virtual) es dictada por el profesor Gómez Rolando de 55 años de edad con una antigüedad en la universidad de 20 años.
El profesor Rubén Pérez es tutor del alumno Ramiro Sosa

2.- Ejecutar una consulta que devuelva todas las materias cuya modalidad sea “Virtual”

3.- Que hace la siguiente operación: 
```
MATCH (s:Estudiante)-[:CURSA]->(m:Materia)

RETURN s.Apellido, m.Modalidad
```
## Respuesta

1.- Primero creo los nodos correspondientes a estudiante, materia y profesor. Luego los relaciono.

Creación de nodos:

*Los datos faltantes se inventaron, por ejemplo antigüedad y edad profesor Pérez Rubén.
```
CREATE (sr:Estudiante {Apellido: 'Sosa', Nombre: 'Ramiro', Edad: 20, DNI: 33999888, Nacionalidad: 'Argentina'})
CREATE (f:Materia {Codigo: 'F190', Descripcion: 'Fisica', Dia: 'Miercoles', Modalidad: 'Virtual'})
CREATE (gr:Profesor {Apellido: 'Gomez', Nombre: 'Rolando', Antigüedad: 20, Edad: 55})
CREATE (pr:Profesor {Apellido: 'Perez', Nombre: 'Ruben', Antigüedad: 10, Edad: 45})
```
Relaciones:
```
-- Relaciono Ramiro con Fisica
MATCH (sr:Estudiante {Nombre: 'Ramiro'}), (f:Materia {Descripcion: 'Fisica'})
CREATE (sr)-[:CURSA]->(f)
-- Relaciono profesor con que dicta fisica
MATCH (gr:Profesor {Nombre: 'Rolando'}), (f:Materia {Descripcion: 'Fisica'})
CREATE (gr)-[:DICTA]->(f)
-- Relaciono profesor con que es tutor de Ramiro
MATCH (pr:Profesor {Nombre: 'Ruben'}), (sr:Estudiante {Nombre: 'Ramiro'})
CREATE (pr)-[:TUTOR]->(sr)
```

2.- Ejecutar una consulta que devuelva todas las materias cuya modalidad sea “Virtual”
```
MATCH (m:Materia {Modalidad: 'Virtual'})
RETURN m
```

3.- Que hace la siguiente operación: 
```
MATCH (s:Estudiante)-[:CURSA]->(m:Materia)
RETURN s.Apellido, m.Modalidad
```
Esta operación devuelve el apellido de cada estudiante y la modalidad de cada materia que cursa.
