## Pregunta
Definir las colecciones necesarias para almacenar la información de los usuarios registrados y los propietarios de canchas del siguiente caso de uso.

Considerar cómo organizar la información de manera que sea fácil de recuperar y mantener:

Estás participando en el desarrollo de una plataforma que permite a los usuarios reservar canchas deportivas para diferentes deportes, como fútbol, tenis, y baloncesto. Como ingeniero de bases de datos, tu tarea es diseñar la estructura de la base de datos usando MongoDB. Los usuarios podrán registrarse, buscar canchas disponibles, realizar reservas y dejar reseñas sobre las canchas.

A continuación, van a encontrar los actores principales del sistema y sus características.

**Usuario:**
Características: Nombre de usuario, Correo electrónico, Edad, Categoría ("Adherente", "Vitalicio", "Invitado"), Contraseña, Historial de reservas
Acciones que los usuarios pueden querer realizar: Iniciar sesión, Buscar canchas disponibles, Realizar reservas, Dejar reseñas sobre canchas

**Propietario de Cancha:**
Características: Nombre del propietario, Detalles de contacto (teléfono, correo electrónico), Lista de canchas de su propiedad

**Cancha:**
Características: Número de cancha, Deportes que admite, Costo por hora

**Reserva:**
Características: Número de cancha a reservar, usuario, cantidad de horas, fecha

## Respuesta
Para el caso de uso presentado, una posible organización de las colecciones podría ser la siguiente:

Usuario: {"id_user":1, "nombre_usuario": "Juan", "correo": "juan@gmail.com", "fecha_nac":"1944-12-01", "edad": 80, "categoria": "Adherente", "password":"1234"},
{"id_user":2, "nombre_usuario": "Tadeo", "correo": "tadeo@gmail.com:", "fecha_nac":"2001-12-01", "edad": 22, "categoria": "Vitalicio", "password":"1234"}

Propietario: {"id_propietario":1, "nombre": "Jorge", "telefono": "2284567685", "mail": "jorge@gmail.com"},
{"id_propietario":2, "nombre": "Pedro", "telefono": "2284567685", "mail": "pedro@gmail.com"}

Canchas: {"id_cancha":1, "numero": 1, "deporte": "futbol", "costo_hora": 1000, "id_propietario": 1, "reviews":[{"nombre_usuario": "Juan", "comentario": "Muy buena cancha", "puntaje": 5}]},
{"id_cancha":2, "numero": 2, "deporte": "tenis", "costo_hora": 400, "id_propietario": 1, "reviews":[{"nombre_usuario": "Juan", "comentario": "Muy buena cancha", "puntaje": 5}]}

Reserva: {"id_reserva": 1, "id_usuario": 1, "id_cancha": 1, "horas": 2, "fecha": "2021-01-01", "hora_ingreso": "10:00"}, {"id_reserva": 2, "id_usuario": 2, "id_cancha": 2, "horas": 1, "fecha": "2021-01-01", "hora_ingreso": "11:00"}

Tambien se agregaron las resenas para que los usuarios puedan opinar sobre las canchas que usaron.

Nuevamente esta es solo una manera de hacerlo, tambien puede armarse de otras maneras la estructura. Me enfoque en evitar la informacion redundante y que sea facil de mantener y recuperar.

## Preguntas y respuestas
a.- Escribir una consulta que recupere todas las canchas de Tenis o Rugby que cuesten menos de $500 la hora.

```json
    db.canchas.find({$or: [{"deporte": "tenis"}, {"deporte": "rugby"}], "costo_hora": {$lt: 500}});
```

b.- Escribir una consulta que recupere todos los propietarios de canchas de Rugby mostrando solo su Nombre y teléfono
```json
db.canchas.aggregate([
    {$match: {"deporte": "rugby"}},
    {$lookup: {
        from: "propietarios",
        localField: "id_propietario",
        foreignField: "id_propietario",
        as: "propietario_info"
    }},
    {$project: {"propietario_info.nombre": 1, "propietario_info.telefono": 1}}
])
```

c.- Generar una nueva reserva para un usuario determinado
```json
    db.reservas.insert({"id_reserva": 3, "id_usuario": 1, "id_cancha": 1, "horas": 2, "fecha": "2024-02-19", "hora_ingreso": "10:00"})
    // Mostrar todas las reservas
    db.reservas.find()
```

d.- Actualizar la categoría de todos los socios de mas de 80 años a "Vitalicio"
```json
    db.usuarios.updateMany({"edad": {$gt: 80}}, {$set: {"categoria": "Vitalicio"}})
    db.usuarios.find()

    // Nada que ver, pero si quisiera usar un AND seria asi
    db.usuarios.updateMany(
    {$and: [{"edad": {$gt: 80}}, {"nombreUsuario": "tadeo"}]},
    {$set: {"categoria": "Vitalicio"}}
)
```

e.- Generar una operación que permita calcular cuantos propietarios de canchas poseen mas de 3 canchas de tenis
```json
    db.canchas.aggregate([
        {$match: {"deporte": "tenis"}},
        {$group: {_id: "$id_propietario", count: {$sum: 1}}},
        {$match: {"count": {$gt: 0}}},
        {$count: "total"}
    ])
```
