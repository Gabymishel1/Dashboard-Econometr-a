# ── Librerías ─────────────────────────────────────────────────────────────────
library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(tidyr)
library(scales)

# ── Datos ─────────────────────────────────────────────────────────────────────
gap <- read.csv("data/processed/gapminder_processed.csv")

years      <- sort(unique(gap$year))
continents <- c("Todos", sort(unique(gap$continent)))

COLORS <- c(
  Africa   = "#E05C3A",
  Americas = "#1FAD82",
  Asia     = "#3A8FD4",
  Europe   = "#7B6FD4",
  Oceania  = "#D44F7B"
)

CHART_BG <- "#f8f9fa"

# ── Helper: stat card ─────────────────────────────────────────────────────────
stat_card <- function(title, output_id, color, icon_emoji) {
  div(
    style = paste0(
      "background:#ffffff; border-radius:12px; padding:0.85rem 1.1rem 1rem 1.1rem; ",
      "box-shadow:0 2px 10px rgba(0,0,0,0.09); ",
      "border-left:5px solid ", color, "; ",
      "transition:transform 0.15s ease, box-shadow 0.15s ease; ",
      "display:flex; flex-direction:column; gap:0.4rem; ",
      "min-height:90px; box-sizing:border-box; overflow:visible;"
    ),
    onmouseover = "this.style.transform='translateY(-2px)';this.style.boxShadow='0 6px 20px rgba(0,0,0,0.13)'",
    onmouseout  = "this.style.transform='';this.style.boxShadow='0 2px 10px rgba(0,0,0,0.09)'",
    div(
      span(icon_emoji, style = "font-size:1.1rem; line-height:1;"),
      span(title, style = paste0(
        "font-size:0.65rem; font-weight:700; text-transform:uppercase; ",
        "letter-spacing:0.09em; color:", color, "; white-space:nowrap;"
      )),
      style = "display:flex; align-items:center; gap:0.45rem;"
    ),
    div(
      textOutput(output_id),
      style = "font-size:1.15rem; font-weight:800; color:#111111; line-height:1.2; padding-top:0.05rem;"
    )
  )
}

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- page_navbar(
  title = span(
    style = "font-weight:700; font-size:1.1rem; letter-spacing:0.02em;",
    "🌍 Gapminder Dashboard"
  ),
  theme = bs_theme(
    bootswatch   = "quartz",
    base_font    = font_google("Inter"),
    heading_font = font_google("Inter"),
    primary      = "#6f42c1",
    secondary    = "#6c757d"
  ),
  
  header = tags$head(
    tags$style(HTML("

      /* ── Navbar ── */
      .navbar {
        background: linear-gradient(135deg, #2d1b69 0%, #6f42c1 100%) !important;
        padding: 0.6rem 1.5rem;
        box-shadow: 0 2px 12px rgba(0,0,0,0.25);
      }
      .navbar-brand, .navbar .nav-link {
        color: #ffffff !important;
        opacity: 0.9;
      }
      .navbar .nav-link.active {
        color: #ffffff !important;
        opacity: 1;
        border-bottom: 2px solid #c9a9f5;
        font-weight: 600;
      }
      .navbar .nav-link:hover {
        opacity: 1;
        color: #c9a9f5 !important;
      }

      /* ── Sidebar blanco ── */
      .bslib-sidebar-layout > .sidebar {
        background-color: #ffffff !important;
        border-right: 1px solid #dee2e6 !important;
        box-shadow: 2px 0 10px rgba(0,0,0,0.08) !important;
      }
      .sidebar .sidebar-title {
        font-size: 0.7rem !important;
        font-weight: 700 !important;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: #6f42c1 !important;
        padding-bottom: 0.5rem;
        border-bottom: 2px solid #6f42c1;
        margin-bottom: 1rem;
      }
      .sidebar label {
        font-size: 0.78rem !important;
        font-weight: 600 !important;
        color: #212529 !important;
        margin-bottom: 0.2rem;
      }
      .sidebar .form-select,
      .sidebar .form-control {
        font-size: 0.82rem !important;
        border-radius: 6px;
        border: 1px solid #ced4da;
        color: #212529 !important;
        background-color: #ffffff !important;
      }
      .sidebar .form-select:focus,
      .sidebar .form-control:focus {
        border-color: #6f42c1;
        box-shadow: 0 0 0 0.15rem rgba(111,66,193,0.25);
      }
      .irs--shiny .irs-min,
      .irs--shiny .irs-max,
      .irs--shiny .irs-grid-text {
        color: #495057 !important;
      }

      /* ── Cards generales ── */
      .card {
        border-radius: 12px !important;
        box-shadow: 0 2px 10px rgba(0,0,0,0.10) !important;
        transition: box-shadow 0.2s ease;
        background: #ffffff !important;
      }
      .card:hover {
        box-shadow: 0 4px 18px rgba(0,0,0,0.16) !important;
      }
      .card-header {
        background: #ffffff !important;
        border-bottom: 1px solid #f0f0f0 !important;
        border-radius: 12px 12px 0 0 !important;
        font-size: 0.82rem !important;
        font-weight: 700 !important;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: #495057 !important;
        padding: 0.85rem 1.1rem !important;
      }

      /* ── Main content padding ── */
      .bslib-page-navbar > .tab-content {
        padding: 1.2rem 1.5rem !important;
      }

      /* ── Slider morado ── */
      .irs--shiny .irs-bar,
      .irs--shiny .irs-from,
      .irs--shiny .irs-to,
      .irs--shiny .irs-single {
        background: #6f42c1 !important;
        border-color: #6f42c1 !important;
        color: #ffffff !important;
      }
      .irs--shiny .irs-handle {
        border-color: #6f42c1 !important;
        background: #6f42c1 !important;
      }
      .irs--shiny .irs-handle:hover,
      .irs--shiny .irs-handle.state_hover {
        background: #5a2d9e !important;
        border-color: #5a2d9e !important;
      }
      .irs--shiny .irs-grid-pol {
        background: #6f42c1 !important;
      }

    "))
  ),
  
  sidebar = sidebar(
    title = "Filtros",
    sliderInput("year", "Año:",
                min = min(years), max = max(years),
                value = 2007, step = 5, sep = ""
    ),
    selectInput("continent", "Continente:",
                choices = continents, selected = "Todos"
    ),
    selectInput("variable", "Variable principal:",
                choices = c(
                  "Esperanza de vida" = "lifeExp",
                  "PIB per cápita"    = "gdpPercap",
                  "Población"         = "pop"
                ),
                selected = "lifeExp"
    )
  ),
  
  # ── Página 1: Overview ─────────────────────────────────────────────────────
  nav_panel("Overview",
            layout_columns(
              col_widths = c(3, 3, 3, 3),
              stat_card("Países",           "kpi_paises", "#3b82f6", "🌐"),
              stat_card("Esp. vida prom.",  "kpi_vida",   "#10b981", "❤️"),
              stat_card("PIB per cápita",   "kpi_gdp",    "#f97316", "💰"),
              stat_card("Población total",  "kpi_pop",    "#8b5cf6", "👥")
            ),
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header("Esperanza de vida por continente"),
                plotlyOutput("bar_continente", height = "300px")
              ),
              card(
                card_header("Top 10 países — variable seleccionada"),
                div(style = "overflow-y: auto; max-height: 420px;",
                    plotlyOutput("bar_top10", height = "420px"))
              )
            ),
            card(
              card_header("Relación entre variables principales"),
              plotlyOutput("scatter_overview", height = "350px")
            )
  ),
  
  # ── Página 2: Mapa ─────────────────────────────────────────────────────────
  nav_panel("Mapa",
            card(
              card_header("Mapa coroplético mundial — variable seleccionada"),
              plotlyOutput("mapa_coropletico", height = "520px")
            )
  ),
  
  # ── Página 3: Tendencias ───────────────────────────────────────────────────
  nav_panel("Tendencias",
            card(
              card_header("Evolución temporal por continente (1952–2007)"),
              plotlyOutput("lineas_tendencia", height = "340px")
            ),
            layout_columns(
              col_widths = c(7, 5),
              card(
                card_header("Regresión lineal — variable vs año"),
                plotlyOutput("regresion", height = "320px")
              ),
              card(
                card_header("Proyecciones 2012 / 2017 / 2022"),
                tableOutput("tabla_proyecciones")
              )
            )
  ),
  
  # ── Página 4: Burbujas ─────────────────────────────────────────────────────
  nav_panel("Burbujas",
            card(
              card_header("PIB per cápita vs Esperanza de vida — animado por año · Tamaño = Población"),
              plotlyOutput("bubble_chart", height = "560px")
            )
  ),
  
  # ── Página 5: Rankings ─────────────────────────────────────────────────────
  nav_panel("Rankings",
            card(
              card_header("Top 15 países — variable seleccionada"),
              plotlyOutput("rankings_bar", height = "520px")
            )
  )
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  
  datos <- reactive({
    df <- gap |> filter(year == input$year)
    if (input$continent != "Todos") df <- df |> filter(continent == input$continent)
    df
  })
  
  datos_tiempo <- reactive({
    df <- gap
    if (input$continent != "Todos") df <- df |> filter(continent == input$continent)
    df
  })
  
  # ── KPIs ───────────────────────────────────────────────────────────────────
  output$kpi_paises <- renderText({ nrow(datos()) })
  
  output$kpi_vida <- renderText({
    paste0(round(mean(datos()$lifeExp, na.rm = TRUE), 1), " años")
  })
  
  output$kpi_gdp <- renderText({
    paste0("$", formatC(round(mean(datos()$gdpPercap, na.rm = TRUE)),
                        format = "f", digits = 0, big.mark = ","))
  })
  
  output$kpi_pop <- renderText({
    total <- sum(datos()$pop, na.rm = TRUE)
    if (total >= 1e9) paste0(round(total / 1e9, 1), "B")
    else paste0(round(total / 1e6, 1), "M")
  })
  
  # ── Barras por continente ──────────────────────────────────────────────────
  output$bar_continente <- renderPlotly({
    df <- datos() |>
      group_by(continent) |>
      summarise(valor = mean(.data[[input$variable]], na.rm = TRUE), .groups = "drop")
    
    plot_ly(df, x = ~continent, y = ~valor, type = "bar",
            marker = list(color = unname(COLORS[df$continent]),
                          line  = list(width = 0)),
            text = ~round(valor, 1), textposition = "outside",
            textfont = list(size = 11, color = "#495057")) |>
      layout(xaxis = list(title = "", tickfont = list(size = 11)),
             yaxis = list(title = input$variable, tickfont = list(size = 11),
                          gridcolor = "#eeeeee"),
             showlegend    = FALSE,
             plot_bgcolor  = CHART_BG,
             paper_bgcolor = "white",
             margin        = list(t = 10, b = 10))
  })
  
  # ── Top 10 países ──────────────────────────────────────────────────────────
  output$bar_top10 <- renderPlotly({
    df <- datos() |>
      arrange(desc(.data[[input$variable]])) |>
      slice(1:10)
    
    plot_ly(df,
            x = ~.data[[input$variable]],
            y = ~reorder(country, .data[[input$variable]]),
            type = "bar", orientation = "h",
            marker = list(color = unname(COLORS[df$continent]),
                          line  = list(width = 0)),
            text = ~round(.data[[input$variable]], 1),
            textposition = "outside",
            textfont = list(size = 11)) |>
      layout(
        xaxis = list(title = input$variable, tickfont = list(size = 11),
                     gridcolor = "#eeeeee"),
        yaxis = list(title = "", automargin = TRUE, tickfont = list(size = 11)),
        showlegend    = FALSE,
        plot_bgcolor  = CHART_BG,
        paper_bgcolor = "white",
        margin        = list(l = 10, r = 60, t = 10, b = 10)
      )
  })
  
  # ── Scatter relación variables ─────────────────────────────────────────────
  output$scatter_overview <- renderPlotly({
    df <- datos()
    plot_ly(df,
            x = ~gdpPercap, y = ~lifeExp, size = ~pop,
            color = ~continent, colors = COLORS,
            type = "scatter", mode = "markers",
            sizes = c(5, 60),
            marker = list(opacity = 0.75, line = list(width = 0.5, color = "white")),
            text = ~paste0("<b>", country, "</b><br>",
                           "PIB: $", round(gdpPercap), "<br>",
                           "Vida: ", round(lifeExp, 1), " años<br>",
                           "Pob: ", round(pop / 1e6, 1), "M"),
            hoverinfo = "text") |>
      layout(xaxis = list(title = "PIB per cápita (USD)", type = "log",
                          tickfont = list(size = 11), gridcolor = "#eeeeee"),
             yaxis = list(title = "Esperanza de vida (años)",
                          tickfont = list(size = 11), gridcolor = "#eeeeee"),
             legend = list(font = list(size = 11)),
             plot_bgcolor  = CHART_BG,
             paper_bgcolor = "white")
  })
  
  # ── Mapa coroplético ───────────────────────────────────────────────────────
  output$mapa_coropletico <- renderPlotly({
    df <- datos()
    label_var <- switch(input$variable,
                        lifeExp   = "Esp. vida (años)",
                        gdpPercap = "PIB per cápita (USD)",
                        pop       = "Población"
    )
    plot_ly(df,
            type         = "choropleth",
            locations    = ~country,
            locationmode = "country names",
            z            = ~.data[[input$variable]],
            text         = ~paste0("<b>", country, "</b><br>",
                                   label_var, ": ", round(.data[[input$variable]], 1)),
            hoverinfo    = "text",
            colorscale   = list(c(0,"#FFF9C4"), c(0.5,"#F4813A"), c(1,"#8B0000")),
            colorbar     = list(title = label_var,
                                tickfont = list(size = 10))) |>
      layout(geo = list(showframe      = FALSE,
                        showcoastlines = TRUE,
                        coastlinecolor = "#aaaaaa",
                        showland       = TRUE,
                        landcolor      = "#f5f5f5",
                        showocean      = TRUE,
                        oceancolor     = "#dce9f5",
                        projection     = list(type = "natural earth")),
             paper_bgcolor = "white",
             margin = list(t = 0, b = 0, l = 0, r = 0))
  })
  
  # ── Líneas de tendencia ────────────────────────────────────────────────────
  output$lineas_tendencia <- renderPlotly({
    df <- gap |>
      group_by(continent, year) |>
      summarise(valor = mean(.data[[input$variable]], na.rm = TRUE), .groups = "drop")
    if (input$continent != "Todos") df <- df |> filter(continent == input$continent)
    
    plot_ly(df, x = ~year, y = ~valor,
            color = ~continent, colors = COLORS,
            type = "scatter", mode = "lines+markers",
            line   = list(width = 2.5),
            marker = list(size = 6),
            text = ~paste0(continent, " ", year, ": ", round(valor, 1)),
            hoverinfo = "text") |>
      layout(xaxis = list(title = "Año", tickfont = list(size = 11),
                          gridcolor = "#eeeeee"),
             yaxis = list(title = input$variable, tickfont = list(size = 11),
                          gridcolor = "#eeeeee"),
             legend = list(font = list(size = 11)),
             plot_bgcolor  = CHART_BG,
             paper_bgcolor = "white")
  })
  
  # ── Regresión lineal ───────────────────────────────────────────────────────
  output$regresion <- renderPlotly({
    df <- gap |>
      group_by(year) |>
      summarise(valor = mean(.data[[input$variable]], na.rm = TRUE), .groups = "drop")
    modelo  <- lm(valor ~ year, data = df)
    df$pred <- predict(modelo)
    
    plot_ly() |>
      add_trace(data = df, x = ~year, y = ~valor,
                type = "scatter", mode = "markers", name = "Dato real",
                marker = list(color = "#3A8FD4", size = 9,
                              line = list(width = 1, color = "white"))) |>
      add_trace(data = df, x = ~year, y = ~pred,
                type = "scatter", mode = "lines", name = "Regresión lineal",
                line = list(color = "#E05C3A", width = 2.5, dash = "dash")) |>
      layout(xaxis = list(title = "Año", tickfont = list(size = 11),
                          gridcolor = "#eeeeee"),
             yaxis = list(title = input$variable, tickfont = list(size = 11),
                          gridcolor = "#eeeeee"),
             plot_bgcolor  = CHART_BG,
             paper_bgcolor = "white",
             legend = list(orientation = "h", font = list(size = 11),
                           y = -0.2))
  })
  
  # ── Proyecciones ───────────────────────────────────────────────────────────
  output$tabla_proyecciones <- renderTable({
    df <- gap |>
      group_by(year) |>
      summarise(valor = mean(.data[[input$variable]], na.rm = TRUE), .groups = "drop")
    modelo       <- lm(valor ~ year, data = df)
    años_futuros <- data.frame(year = c(2012, 2017, 2022))
    años_futuros$Proyección <- round(predict(modelo, años_futuros), 2)
    colnames(años_futuros)  <- c("Año", "Valor proyectado")
    años_futuros
  }, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
  
  # ── Burbuja animada ────────────────────────────────────────────────────────
  output$bubble_chart <- renderPlotly({
    df <- gap
    if (input$continent != "Todos") df <- df |> filter(continent == input$continent)
    
    df$marker_color <- unname(COLORS[df$continent])
    
    plot_ly(df,
            x         = ~gdpPercap,
            y         = ~lifeExp,
            size      = ~pop,
            split     = ~country,
            frame     = ~year,
            type      = "scatter",
            mode      = "markers",
            sizes     = c(5, 80),
            marker    = list(color    = ~marker_color,
                             opacity  = 0.78,
                             sizemode = "diameter",
                             line     = list(width = 0.8, color = "white")),
            text      = ~paste0("<b>", country, "</b><br>",
                                "Continente: ", continent, "<br>",
                                "PIB: $", round(gdpPercap), "<br>",
                                "Vida: ", round(lifeExp, 1), " años<br>",
                                "Pob: ", round(pop / 1e6, 1), "M"),
            hoverinfo = "text") |>
      layout(
        xaxis  = list(title = "PIB per cápita (USD)", type = "log",
                      range = c(log10(200), log10(120000)),
                      tickfont = list(size = 11), gridcolor = "#eeeeee"),
        yaxis  = list(title = "Esperanza de vida (años)", range = c(20, 90),
                      tickfont = list(size = 11), gridcolor = "#eeeeee"),
        legend = list(title = list(text = "<b>País</b>"),
                      font  = list(size = 10)),
        plot_bgcolor  = CHART_BG,
        paper_bgcolor = "white"
      ) |>
      animation_opts(frame = 800, easing = "linear", redraw = FALSE) |>
      animation_slider(currentvalue = list(prefix = "Año: "))
  })
  
  # ── Rankings ───────────────────────────────────────────────────────────────
  output$rankings_bar <- renderPlotly({
    df <- datos() |>
      arrange(desc(.data[[input$variable]])) |>
      slice(1:15)
    
    plot_ly(df,
            x            = ~.data[[input$variable]],
            y            = ~reorder(country, .data[[input$variable]]),
            type         = "bar",
            orientation  = "h",
            marker       = list(color = unname(COLORS[df$continent]),
                                line  = list(width = 0)),
            text         = ~round(.data[[input$variable]], 1),
            textposition = "outside",
            textfont     = list(size = 11)) |>
      layout(xaxis         = list(title = input$variable,
                                  tickfont = list(size = 11),
                                  gridcolor = "#eeeeee"),
             yaxis         = list(title = "", automargin = TRUE,
                                  tickfont = list(size = 11)),
             showlegend    = FALSE,
             plot_bgcolor  = CHART_BG,
             paper_bgcolor = "white",
             margin        = list(l = 10, r = 60))
  })
}

# ── Lanzar ────────────────────────────────────────────────────────────────────
shinyApp(ui, server)