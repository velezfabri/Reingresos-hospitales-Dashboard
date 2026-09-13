# Subir el proyecto a GitHub y compartirlo

## 1. Preparar la carpeta

Descomprimir el paquete y usar la carpeta `hospital-readmissions-powerbi`, donde están `README.md`, `data`, `powerbi`, `sql`, `images` y `docs`. Incluye los archivos nuevos adjuntos, con nombres normalizados sin los sufijos `(1)` y `(2)`.

Se puede conservar el nombre de la carpeta local original; GitHub puede tener otro nombre. Lo importante es iniciar Git en la carpeta que contiene el README y las tres carpetas de trabajo. Subir el contenido descomprimido, no el ZIP como un único archivo.

## 2. Crear el repositorio

Abrir [GitHub: nuevo repositorio](https://github.com/new) e iniciar sesión en la cuenta propia.

- **Repository name:** `hospital-readmissions-powerbi`.
- **Description:** `Análisis de reingresos hospitalarios con SQL Server y Power BI: preparación de datos, KPIs e informe interactivo.`
- **Visibility:** Public, si se quiere compartir como portfolio.
- Dejar desactivadas las opciones para agregar README, `.gitignore` o licencia: el contenido ya está preparado.

Crear el repositorio vacío y copiar su URL HTTPS. Los comandos siguientes suponen la cuenta `velezfabri`; si se usa otra cuenta o nombre, reemplazar la URL por la que muestra GitHub.

## 3. Subirlo con Git Bash

En el Explorador de Windows, abrir la carpeta del proyecto, hacer clic derecho en un espacio vacío y elegir **Open Git Bash here** / **Git Bash Here**. Puede estar dentro de «Mostrar más opciones».

Si esta carpeta todavía no tiene un repositorio Git, ejecutar:

```bash
git init -b main
git add .
git status
git commit -m "Agregar análisis de reingresos hospitalarios con SQL y Power BI"
git remote add origin https://github.com/velezfabri/hospital-readmissions-powerbi.git
git push -u origin main
```

Completar el inicio de sesión de GitHub en el navegador si Git lo solicita. No hace falta conectar una aplicación de GitHub a ChatGPT.

Si Git pide configurar la identidad del autor, usar el nombre propio y el correo verificado en GitHub —o el correo `noreply` que figura en la configuración de GitHub— y repetir el commit. Esa configuración puede hacerse solo para este repositorio con `git config user.name` y `git config user.email`.

Si la carpeta ya estaba versionada, ejecutar primero `git status` y `git remote -v`; no agregar otro `origin` ni cambiar una URL existente sin comprobar cuál es. No se necesita forzar el push para este proyecto.

Los archivos actuales están por debajo de 25 MiB cada uno; el mayor es `diabetic_data.csv`, de aproximadamente 18,3 MiB. No requieren Git LFS. [Límites de archivos de GitHub](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github).

Procedimiento basado en [la guía de GitHub para agregar un proyecto local](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github).

## 4. Verificar y compartir

Una vez completado el push, abrir el repositorio y comprobar que:

- Se muestre el README con las cinco imágenes.
- Estén `data`, `sql`, `powerbi`, `images` y `docs`.
- El enlace «Descargar informe (.pbix)» descargue el informe actualizado.

Si se utilizó el nombre sugerido en la cuenta indicada, la URL para compartir será:

`https://github.com/velezfabri/hospital-readmissions-powerbi`

Quien quiera solo conocer el proyecto puede leer el README. Quien quiera usar los filtros puede elegir **Code → Download ZIP**, descomprimir y abrir el archivo de `powerbi/` con Power BI Desktop para Windows.

En **About**, se pueden agregar los temas `power-bi`, `sql-server`, `healthcare`, `data-analysis` y `portfolio`. El repositorio también se puede fijar en el perfil de GitHub.

## 5. Actualizarlo más adelante

Después de guardar cambios en el PBIX o editar los documentos:

```bash
git add .
git commit -m "Actualizar dashboard y documentación"
git push
```

Para usar una captura exacta de Power BI en el README, guardar una imagen limpia del lienzo como `images/dashboard.png` y actualizar la leyenda que hoy indica «Vista estática recreada». Esa mejora visual no es un requisito para publicar esta versión.

## ¿Se puede compartir de forma interactiva en un navegador?

GitHub aloja los archivos y las imágenes; no ejecuta un `.pbix` dentro del README. Power BI Service ofrece **Publicar en la web**, sujeto a los permisos, la licencia aplicable y la configuración de la cuenta. Esa opción hace público el informe y sus datos subyacentes. El proyecto puede compartirse como portfolio con GitHub y el PBIX descargable sin depender de ella. [Microsoft: publicar en la web](https://learn.microsoft.com/en-us/power-bi/collaborate-share/service-publish-to-web).
