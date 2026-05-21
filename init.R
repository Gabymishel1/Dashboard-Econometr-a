# init.R — Instalar dependencias y preparar el dataset
# Ejecutar una sola vez antes de arrancar la app

# ── 1. Instalar paquetes ──────────────────────────────────────────────────────
paquetes <- c("shiny", "shinydashboard", "plotly", "dplyr",
              "tidyr", "gapminder", "scales", "bslib")

instalados <- rownames(installed.packages())

for (pkg in paquetes) {
  if (!pkg %in% instalados) {
    message("Instalando: ", pkg)
    install.packages(pkg, dependencies = TRUE)
  } else {
    message("Ya instalado: ", pkg)
  }
}

# ── 2. Cargar y exportar el dataset ──────────────────────────────────────────
library(gapminder)
library(dplyr)

# Ver primeras filas para confirmar que cargó bien
head(gapminder)

# Guardar CSV procesado (listo para usar en app.R)
write.csv(gapminder, "data/processed/gapminder_processed.csv", row.names = FALSE)

# Guardar también el TSV original en raw/
write.table(gapminder, "data/raw/gapminder.tsv", sep = "\t", row.names = FALSE, quote = FALSE)

message("✅ Dataset guardado en data/processed/gapminder_processed.csv")
message("✅ Instalación completa. Ya puedes abrir app.R y ejecutar la app.")