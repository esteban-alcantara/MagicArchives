# Ministerio de Magia

## Objetivo

Crear una aplicación que permita consultar expedientes de personajes y explorar un archivo mágico de Harry Potter.

La aplicación tendrá tres pantallas principales en una **Tab Bar**:

- Expedientes
- Archivo mágico
- Guardados

Utiliza los archivos JSON y las imágenes proporcionados. Los colores personalizados son opcionales.

## 1. Expedientes

### Lista de personajes

Muestra una lista de personajes en una `UITableView` con celdas personalizadas. Cada celda incluirá:

- Imagen.
- Nombre.
- Ocupación.
- Casa.
- Etiqueta **“SE BUSCA”** y recompensa en galeones, únicamente cuando el personaje tenga una recompensa.

### Búsqueda y filtros

Incluye un buscador por **nombre u ocupación** y botones para filtrar por casa:

- Todos
- Gryffindor
- Slytherin
- Ravenclaw
- Hufflepuff
- Sin casa

La búsqueda y el filtro por casa deben funcionar simultáneamente. La búsqueda no distinguirá mayúsculas ni acentos.

Si no hay coincidencias, muestra un mensaje y una opción para restablecer la búsqueda y los filtros.

Al seleccionar un personaje, abre su detalle. Al regresar a la lista, conserva la búsqueda y la casa seleccionada.

### Detalle del personaje

Muestra la información del personaje seleccionado:

- Imagen.
- Nombre.
- Ocupación.
- Casa.
- Afiliación.
- Estado del expediente.
- Antecedentes o descripción.
- Recompensa en galeones, únicamente cuando exista.

El contenido debe permitir desplazamiento vertical cuando no quepa en pantalla.

Incluye un botón para guardar o quitar al personaje de favoritos:

| Estado del personaje | Texto del botón |
| --- | --- |
| No está guardado | Guardar expediente |
| Ya está guardado | Quitar de guardados |

Al presionarlo, actualiza los favoritos y el estado del botón. No deben existir personajes duplicados en favoritos.

Los cambios deben conservarse después de cerrar y abrir la aplicación mediante `UserDefaults`.

## 2. Archivo mágico

### Catálogo

Muestra una `UICollectionView` con tres secciones:

| Sección | Cantidad de elementos | Diseño |
| --- | --- | --- |
| Hechizos | 15 | Carrusel horizontal de una fila con tarjetas grandes. |
| Pociones | 10 | Carrusel horizontal de dos filas, con imagen a la izquierda e información a la derecha. |
| Objetos misteriosos | 10 | Cuadrícula vertical de dos columnas. |

Cada sección tendrá un encabezado con su nombre. Las tarjetas mostrarán:

- Imagen.
- Nombre.
- Uso o clasificación.

### Búsqueda

Incluye un buscador por **nombre, tipo o uso**. La búsqueda no distinguirá mayúsculas ni acentos.

- Oculta temporalmente las secciones sin coincidencias.
- Conserva el diseño de cada categoría durante la búsqueda.
- Si no hay resultados, muestra un mensaje.
- Al limpiar la búsqueda, recupera el catálogo completo.

Al seleccionar un elemento, abre su detalle. Al regresar al catálogo, conserva la búsqueda.

### Detalle del elemento mágico

Utiliza una pantalla reutilizable para mostrar la información de hechizos, pociones y objetos:

- Imagen.
- Nombre.
- Categoría.
- Tipo o clasificación.
- Descripción completa.
- Uso principal.
- Dificultad, cuando exista.
- Nivel de peligro.
- Fórmula, cuando exista.
- Precauciones u observaciones.

Muestra los distintivos **“Imperdonable”**, **“Horrocrux”** y **“Acceso restringido”** cuando correspondan a los datos del elemento.

Los campos sin información deberán ocultarse. El contenido debe permitir desplazamiento vertical cuando sea necesario.

## 3. Guardados

### Lista de favoritos

Muestra una `UITableView` con los personajes que el usuario haya guardado como favoritos. Las celdas tendrán el mismo formato que la lista de expedientes.

Al seleccionar un personaje, abre su detalle y permite quitarlo de favoritos mediante el botón.

### Eliminación de favoritos

También será posible eliminar un favorito deslizando su fila. Antes de eliminarlo, muestra una alerta con las opciones:

- **Cancelar**
- **Eliminar**

Los cambios deberán actualizar tanto la lista como los datos persistidos en `UserDefaults`. Al regresar a esta pantalla, muestra la información actualizada.

### Estado vacío

Cuando no existan favoritos, muestra un mensaje indicando que todavía no hay expedientes guardados.
