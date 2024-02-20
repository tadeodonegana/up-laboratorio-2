## Preguntas y respuestas
1.- Estás trabajando en el desarrollo de una plataforma de streaming musical basada en Neo4j. La plataforma incluye información sobre artistas, álbumes, canciones y usuarios. Modelar esta información en una base de datos de grafos y realizar consultas que involucren la relación entre usuarios, canciones, y artistas.

Crear Nodos y Relaciones para representar a los usuarios, artistas, álbumes y canciones sabiendo que de cada usuario conocemos su apellido, edad, nombre de usuario. 

De cada artista sabemos su nombre artístico, género musical que interpreta. 

De cada álbum sabemos el año en que se estrenó, la cantidad de canciones que tiene, el título y a que artista pertenece. 

De cada canción sabemos el titulo y la duración y a que álbum pertenece, y también a que artista pertenece (en un mismo álbum de un mismo artista puede haber canciones que no sean de su autoría).

Luego sabemos que:

a.- Juan Pérez, alias jperez89, de 25 años escucha canciones del genero pop como "Donde están los ladrones" de Shakira, que dura 4 minutos y que pertenece al álbum "Pies descalzos" que tiene 20 temas y que salio en el anio 1999.

b.- Romina Galván, alias Romi_100 de 34 años escucha canciones del género Rock como "El Revelde", de la Renga, que dura 3,30 minutos y que pertenece al álbum "La Renga" que tiene otros 15 temas.

Creacion de Nodos:
```
CREATE (jp:Usuario {Nombre: 'Juan', Apellido: 'Perez', Username: 'jperez89', Edad: 25})
CREATE (rg:Usuario {Nombre: 'Romina', Apellido: 'Galvan', Username: 'Romi_100', Edad: 34})
CREATE (sh:Artista {Nombre: 'Shakira', Genero: 'Pop'})
CREATE (lr:Artista {Nombre: 'La Renga', Genero: 'Rock'})
CREATE (pd:Album {Titulo: 'Pies descalzos', Anio: 1999, CantCanciones: 20})
CREATE (lra:Album {Titulo: 'La Renga', Anio: 2000, CantCanciones: 16}) -- Se asumio el anio aca por que no dice
CREATE (deld: Cancion {Titulo: 'Donde estan los ladrones', Duracion: 4})
CREATE (elr: Cancion {Titulo: 'El Revelde', Duracion: 3.30})
```
Relaciones:
```
-- Relaciono Juan con Shakira
MATCH (jp:Usuario {Nombre: 'Juan'}), (sh:Artista {Nombre: 'Shakira'})
CREATE (jp)-[:ESCUCHA]->(sh)
-- Relaciono Shakira con Pies descalzos
MATCH (sh:Artista {Nombre: 'Shakira'}), (pd:Album {Titulo: 'Pies descalzos'})
CREATE (sh)-[:INTERPRETA]->(pd)
-- Relaciono Shakira con Donde estan los ladrones
MATCH (sh:Artista {Nombre: 'Shakira'}), (deld:Cancion {Titulo: 'Donde estan los ladrones'})
CREATE (sh)-[:INTERPRETA]->(deld)
-- Relaciono Pies descalzos con Donde estan los ladrones
MATCH (pd:Album {Titulo: 'Pies descalzos'}), (deld:Cancion {Titulo: 'Donde estan los ladrones'})
CREATE (pd)-[:CONTIENE]->(deld)
-- Relaciono Romina con La Renga
MATCH (rg:Usuario {Nombre: 'Romina'}), (lr:Artista {Nombre: 'La Renga'})
CREATE (rg)-[:ESCUCHA]->(lr)
-- Relaciono La Renga con El Revelde
MATCH (lr:Artista {Nombre: 'La Renga'}), (elr:Cancion {Titulo: 'El Revelde'})
CREATE (lr)-[:INTERPRETA]->(elr)
-- Relaciono La Renga con La Renga
MATCH (lr:Artista {Nombre: 'La Renga'}), (lra:Album {Titulo: 'La Renga'})
CREATE (lr)-[:INTERPRETA]->(lra)
-- Relaciono La Renga con El Revelde
MATCH (lra:Album {Titulo: 'La Renga'}), (elr:Cancion {Titulo: 'El Revelde'})
CREATE (lra)-[:CONTIENE]->(elr)
```

2.- Ejecutar una consulta que devuelva todos albumes con más de 15 canciones y del género Rock.
```
MATCH (ar:Artista {Genero: 'Rock'})-[:INTERPRETA]->(a:Album) WHERE a.CantCanciones > 15
RETURN a
```

3.- Ejecutar una consulta que devuelve el nombre de usuario y el título de la canción, de aquellos usuarios que tengan más de 45 años y que escuchen canciones de Rock de más de 3 minutos de duración que pertenezcan al artista Charly Garcia.
```
-- Creo artista y relaciones 
CREATE (cg:Artista {Nombre: 'Charly Garcia', Genero: 'Rock'})
CREATE (ta:Album {Titulo: 'Test', Anio: 1999, CantCanciones: 12})
CREATE (ts: Cancion {Titulo: 'Test Cancion', Duracion: 5})

MATCH (jp:Usuario {Nombre: 'Juan'}), (cg:Artista {Nombre: 'Charly Garcia'})
CREATE (jp)-[:ESCUCHA]->(cg)

MATCH (cg:Artista {Nombre: 'Charly Garcia'}), (ta:Album {Titulo: 'Test'})
CREATE (cg)-[:INTERPRETA]->(ta)

MATCH (ta:Album {Titulo: 'Test'}), (ts:Cancion {Titulo: 'Test Cancion'})
CREATE (ta)-[:CONTIENE]->(ts)

MATCH (cg:Artista {Nombre: 'Charly Garcia'}), (ts:Cancion {Titulo: 'Test Cancion'})
CREATE (cg)-[:INTERPRETA]->(ts)

-- Aca abajo se detalla la query en cuestion que pedia el ejercicio.
MATCH (u:Usuario)-[:ESCUCHA]->(ar:Artista {Nombre: 'Charly Garcia'})-[:INTERPRETA]->(c:Cancion) WHERE u.Edad > 45 AND c.Duracion > 3
RETURN u.Nombre, c.Titulo
```

**Para modificar un nodo existente:**
```
MATCH (n:NodeLabel {property: 'value'}) // Replace NodeLabel, property, and 'value' with your actual values
SET n.newProperty = 'newValue' // Replace newProperty and 'newValue' with your actual values
RETURN n
--
MATCH (n:NodeLabel {property: 'value'})
SET n.property1 = 'value1',
    n.property2 = 'value2'
RETURN n
```