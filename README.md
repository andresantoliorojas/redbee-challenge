# "Enunciado"

Generar una herramienta para uso exclusivo de los operadores, asumiendo que no tienen conocimiento para editar o modificar el mismo.

El archivo input.json contiene configuraciones para una orquestador de contenedores (Marathon).

Dentro del mismo se encuentra la definición de N aplicaciones con información respecto al runtime (con que imagen de Docker corre, cuanta RAM/CPU tiene reservada, que puertos reserva/expone, cuantas instancias ocupa, etc.)

Para la resolución y parseo del input se deberá usar la herramienta [jq](https://stedolan.github.io/jq/)

---

## Parte 1:

- Armar un script de Bash (Linux) para obtener todas las aplicaciones que hayan cambiado su configuración (lastChangedAt) en las ultimas X horas. (Por ej: últimas 24 horas).

- La salida del script tiene que tener el nombre de cada aplicación y su fecha de modificación.



**BONUS: Debe verse primero la última que se modifico (lastChangedAt).**
**BONUS: Buscar las aplicaciones con conflicto de puerto, en la definicion de la aplicaciones hay un port (servicePort), ver que no colisionen entre ellos.**



---

## Parte 2:

- Armar una imagen de Docker que permita al operador utilizarla sin necesidad de instalarse jq localmente.

**BONUS: Armar un documento que describa la ejecucion**



# "Documentación"

## Parte 1

Utiliar el script bash denominado **json_filter.sh**, el cual recibe los siguientes parámetros:

- **-f**      Archivo de entrada (requerido)
- **-t**      Ultimas X horas (requerido)
- **-d**      Listar puertos duplicados (opcional)

Requisitos de uso:
- Tener instalada la herramienta **jq**


Modos/Ejemplos de uso

- Filtrar del listado las aplicaciones que fueron modificadas en las ultimas 24 horas
```shell
./json_filter.sh -f input.json -t 24 > output.json
```

- Filtrar del listado las aplicaciones que fueron modificadas en las ultimas 48 horas mostrando además si posee puertos duplicados/colisionados
```shell
./json_filter.sh -f input.json -t 48 -d yes > output.json
```

## Parte 2

A partir del script creado en **parte 1**, se utiliza docker y docker-compose como interfaz para le ejecución del mismo.

Requisitos de uso:
- Tener instalado **docker** y **docker-compose**
- Tanto el script como el archivo de entrada deben estar en el mismo directorio que los manifiestos docker


Modos/Ejemplos de uso:

La modificación de los parámetros se realiza de forma similar a lo explicado anteriormente, solo que ahora los mismos se declaran dentro del manifiesto **docker-compose.yml**, en la sección **command**.
Cabe destacar que el resultado de dicha ejecución se exporta en un volumen llamado **data** (se ubica en el mismo path que el resto de los archivos).

Si se realiza algún cambio en los valores de ejecución del script o simplemente en el manifiesto YAML, alcanza con ejecutar:
```shell
docker-compose up -d
```

En cambio, si se realiza algún cambio en la definición de la imagen de contenedor, será necesario ejecutar
```shell
docker-compose up -d --build
```

Se pueden ver los resultados con cualquier editor de texto o mostrando la salida en pantalla, como por ejemplo:
```shell
cat data/output.json
```
