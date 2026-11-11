#!/bin/bash
dnf install -y nginx
systemctl enable --now nginx

cat > /usr/share/nginx/html/index.html <<EOF
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Librería Tinta</title>
</head>
<body>
  <h1>Librería Tinta</h1>
  <p>Tu librería de barrio.</p>

  <h2>Horario</h2>
  <p>Lunes a viernes: 9:00 a 20:00</p>
  <p>Sábados: 10:00 a 14:00</p>

  <h2>Dirección</h2>
  <p>Calle de los Libros, 12, Sevilla (dirección ficticia)</p>

  <h2>Libro recomendado</h2>
  <p>Don Quijote de la Mancha, de Miguel de Cervantes.</p>

  <hr>
  <small>Desplegado por José Antonio Alguacil en el servidor $(hostname) el $(date '+%d/%m/%Y %H:%M')</small>
</body>
</html>
EOF
