\#  Gapminder Dashboard



Dashboard interactivo construido con \*\*R Shiny\*\* que explora el dataset clásico de \[Gapminder]: esperanza de vida, PIB per cápita y población de 142 países entre 1952 y 2007.



\---



\ ¿Qué permite explorar?



El dashboard responde preguntas como:



\- ¿Qué países tienen mayor esperanza de vida o PIB per cápita en un año dado?

\- ¿Cómo ha evolucionado el bienestar global por continente a lo largo de 55 años?

\- ¿Existe relación entre riqueza y longevidad? ¿Ha cambiado con el tiempo?

\- ¿Qué proyecciones se pueden hacer para años posteriores al dataset?



\---



\  Páginas



\ Overview

Vista general del año y continente seleccionados. Muestra el número de países, esperanza de vida promedio, PIB per cápita promedio y población total como KPIs, junto con un ranking de los 10 países líderes en la variable elegida y un scatter plot que relaciona PIB, esperanza de vida y población simultáneamente.



\ Mapa

Mapa coroplético mundial que colorea cada país según el valor de la variable seleccionada, permitiendo identificar de un vistazo las desigualdades geográficas globales.



\ Tendencias

Evolución temporal de cada continente entre 1952 y 2007. Incluye una regresión lineal sobre el promedio global por año y una tabla con proyecciones estimadas para 2012, 2017 y 2022.



\ Burbujas

Animación año a año que muestra simultáneamente PIB per cápita (eje X, escala log), esperanza de vida (eje Y) y población (tamaño de burbuja). Permite ver cómo se han desplazado los países a lo largo del tiempo y comparar trayectorias entre regiones.



\ Rankings

Top 15 países ordenados por la variable seleccionada para el año y continente activos.



\---



\  Filtros globales



Todas las páginas responden a tres filtros en la barra lateral:



\- \*\*Año\*\* — 1952 a 2007 en intervalos de 5 años

\- \*\*Continente\*\* — África, Américas, Asia, Europa, Oceanía o Todos

\- \*\*Variable principal\*\* — Esperanza de vida, PIB per cápita o Población



\---



\  Dataset



El proyecto usa el paquete \[`gapminder`]de R, que contiene datos de \*\*142 países\*\* en \*\*12 años\*\* (cada 5 años entre 1952 y 2007), con tres variables por observación:



| Variable | Descripción |

|---|---|

| `lifeExp` | Esperanza de vida al nacer (años) |

| `gdpPercap` | PIB per cápita en dólares internacionales ajustados por inflación |

| `pop` | Población total |



El script `init.R` descarga y exporta el dataset a `data/processed/gapminder\_processed.csv` antes de lanzar la app.



\---



\ Cómo ejecutar



```r

\ 1. Solo la primera vez: instala paquetes y genera el CSV

source("init.R")



\ 2. Lanzar la app

shiny::runApp("app.R")

```



\---



