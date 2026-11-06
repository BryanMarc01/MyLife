IdeaStep.delete_all
Idea.delete_all
FinancialTransaction.delete_all
AutomationRule.delete_all

newsletter = Idea.create!(
  title: "Newsletter de paseos",
  summary: "Una ruta, un café y una librería.",
  essential_summary: "Una newsletter semanal para descubrir Madrid a pie: una ruta corta, un café y una librería cada viernes.",
  transcript: "«Podría crear una newsletter de paseos por Madrid. Una ruta corta, un café y una librería cada viernes. Empezar por Malasaña.»",
  category: "Proyectos",
  status_tag: "Por explorar",
  source_kind: "Nota de voz",
  captured_label: "Ahora",
  captured_meta: "6 nov, 9:41 · Capturada por voz · 18 s",
  duration_seconds: 18,
  icon_name: "route",
  featured_today: false,
  visible_in_recent: true,
  next_step_preview: "Dibujar una ruta por Malasaña · Proyectos",
  steps_confirmed: false,
  position: 1
)

[
  "Dibujar una ruta por Malasaña",
  "Elegir un café y una librería",
  "Preparar el primer borrador"
].each_with_index do |desc, idx|
  newsletter.idea_steps.create!(description: desc, completed: false, position: idx + 1)
end

rincon = Idea.create!(
  title: "Un rincón para leer",
  summary: "Luz natural y una pausa sin pantallas.",
  essential_summary: "Acondicionar la butaca junto a la ventana del salón con una lámpara cálida para leer media hora cada tarde sin el móvil cerca.",
  transcript: "«Quiero montar un rincón para leer junto a la ventana. Luz natural, una lámpara pequeña y dejar el móvil fuera.»",
  category: "Personal",
  status_tag: "Por explorar",
  source_kind: "Nota rápida",
  captured_label: "Ayer",
  captured_meta: "5 nov, 19:15 · Nota rápida",
  duration_seconds: 14,
  icon_name: "book-open",
  featured_today: true,
  visible_in_recent: true,
  next_step_preview: "Elegir el lugar · Personal",
  steps_confirmed: false,
  position: 2
)

[
  "Elegir el lugar junto a la ventana",
  "Buscar una lámpara de lectura cálida",
  "Dejar listo el libro de esta semana"
].each_with_index do |desc, idx|
  rincon.idea_steps.create!(description: desc, completed: false, position: idx + 1)
end

ceramica = Idea.create!(
  title: "Taller de cerámica",
  summary: "Buscar una clase para el sábado.",
  essential_summary: "Probar un taller de torno o modelado manual un sábado por la mañana en el barrio para desconectar de la pantalla.",
  transcript: "«Buscar un taller de cerámica de iniciación para ir un sábado por la mañana.»",
  category: "Personal",
  status_tag: "Por explorar",
  source_kind: "Nota de voz",
  captured_label: "4 nov",
  captured_meta: "4 nov, 11:20 · Capturada por voz · 12 s",
  duration_seconds: 12,
  icon_name: "coffee",
  featured_today: false,
  visible_in_recent: true,
  next_step_preview: "Mirar horarios en Chamberí · Personal",
  steps_confirmed: false,
  position: 3
)

[
  "Consultar talleres con plaza en noviembre",
  "Preguntar a Clara si se apunta",
  "Reservar sesión de prueba"
].each_with_index do |desc, idx|
  ceramica.idea_steps.create!(description: desc, completed: false, position: idx + 1)
end

menus = Idea.create!(
  title: "Menús sin improvisar",
  summary: "Cinco recetas para simplificar la semana.",
  essential_summary: "Tener una base fija de cinco cenas rápidas y saludables para comprar de una vez y no pensar cada noche qué cocinar.",
  transcript: "«Elegir cinco recetas sencillas para las cenas de entre semana y dejar la lista de compra fija.»",
  category: "Vida diaria",
  status_tag: "En marcha",
  source_kind: "Nota de voz",
  captured_label: "3 nov",
  captured_meta: "3 nov, 20:05 · Capturada por voz · 16 s",
  duration_seconds: 16,
  icon_name: "utensils",
  featured_today: false,
  visible_in_recent: true,
  next_step_preview: "Anotar ingredientes base · Vida diaria",
  steps_confirmed: false,
  position: 4
)

[
  "Anotar las 5 cenas favoritas",
  "Agrupar ingredientes comunes",
  "Guardar plantilla de compra semanal"
].each_with_index do |desc, idx|
  menus.idea_steps.create!(description: desc, completed: false, position: idx + 1)
end

# 8 ideas adicionales de archivo para completar el conteo exacto de Figma:
# Todas (12) = Proyectos (5) + Personal (4) + Vida diaria (3)
extra_ideas = [
  { title: "Podcast de arquitectura", summary: "Episodios breves sobre edificios cotidianos.", category: "Proyectos", icon_name: "route", captured_label: "1 nov", source_kind: "Nota de voz" },
  { title: "Guía de cafés tranquilos", summary: "Mapa compartido para trabajar o leer a gusto.", category: "Proyectos", icon_name: "coffee", captured_label: "29 oct", source_kind: "Nota rápida" },
  { title: "Archivo fotográfico familiar", summary: "Digitalizar álbumes antiguos por décadas.", category: "Proyectos", icon_name: "book-open", captured_label: "25 oct", source_kind: "Nota de voz" },
  { title: "Rediseño del estudio", summary: "Mesa despejada y mejor luz para invierno.", category: "Proyectos", icon_name: "route", captured_label: "21 oct", source_kind: "Nota rápida" },
  { title: "Escapada a la sierra", summary: "Ruta circular de otoño en tren de cercanías.", category: "Personal", icon_name: "route", captured_label: "18 oct", source_kind: "Nota de voz" },
  { title: "Club de ensayo mensual", summary: "Un libro corto compartido con tres amigos.", category: "Personal", icon_name: "book-open", captured_label: "14 oct", source_kind: "Nota rápida" },
  { title: "Botiquín y despensa de invierno", summary: "Revisar básicos antes de que empiece el frío.", category: "Vida diaria", icon_name: "utensils", captured_label: "10 oct", source_kind: "Nota rápida" },
  { title: "Rutina de domingo tarde", summary: "Preparar ropa y agenda en veinte minutos.", category: "Vida diaria", icon_name: "coffee", captured_label: "6 oct", source_kind: "Nota de voz" }
]

extra_ideas.each_with_index do |attrs, idx|
  idea = Idea.create!(
    title: attrs[:title],
    summary: attrs[:summary],
    essential_summary: attrs[:summary],
    transcript: "«#{attrs[:summary]}»",
    category: attrs[:category],
    status_tag: "Por explorar",
    source_kind: attrs[:source_kind],
    captured_label: attrs[:captured_label],
    captured_meta: "#{attrs[:captured_label]} · #{attrs[:source_kind]}",
    duration_seconds: 15,
    icon_name: attrs[:icon_name],
    featured_today: false,
    visible_in_recent: false,
    position: idx + 5
  )
  idea.idea_steps.create!(description: "Definir el primer paso para #{idea.title.downcase}", completed: false, position: 1)
end

# Movimientos financieros que cuadran exactamente con Figma:
# Ingresos: 3.200 € | Gastos: 720 € (Hogar 420 €, Comida 180 €, Otros 120 €) | Saldo: 2.480,00 €
FinancialTransaction.create!([
  {
    concept: "Compra semanal",
    category: "Comida",
    kind: "expense",
    amount_cents: 4_200, # 42,00 €
    date_label: "Hoy",
    icon_name: "shopping-basket",
    visible_in_recent: true,
    position: 1
  },
  {
    concept: "Café Miga",
    category: "Comida",
    kind: "expense",
    amount_cents: 450, # 4,50 €
    date_label: "Ayer",
    icon_name: "coffee-17",
    visible_in_recent: true,
    position: 2
  },
  {
    concept: "Abono transporte",
    category: "Transporte",
    kind: "expense",
    amount_cents: 3_200, # 32,00 €
    date_label: "4 nov",
    icon_name: "train-front",
    visible_in_recent: true,
    position: 3
  },
  {
    concept: "Alquiler y suministros",
    category: "Hogar",
    kind: "expense",
    amount_cents: 42_000, # 420,00 €
    date_label: "2 nov",
    icon_name: "shopping-basket",
    visible_in_recent: false,
    position: 4
  },
  {
    concept: "Mercado y despensa",
    category: "Comida",
    kind: "expense",
    amount_cents: 13_350, # 133,50 € (Total Comida = 180,00 €)
    date_label: "2 nov",
    icon_name: "shopping-basket",
    visible_in_recent: false,
    position: 5
  },
  {
    concept: "Suscripciones y libros",
    category: "Otros",
    kind: "expense",
    amount_cents: 8_800, # 88,00 € (Total Otros + Transporte = 120,00 €)
    date_label: "1 nov",
    icon_name: "coffee-17",
    visible_in_recent: false,
    position: 6
  },
  {
    concept: "Ingresos noviembre",
    category: "Ingresos",
    kind: "income",
    amount_cents: 320_000, # 3.200,00 €
    date_label: "1 nov",
    icon_name: "shopping-basket",
    visible_in_recent: false,
    position: 7
  }
])

AutomationRule.create!([
  {
    title: "De voz a idea",
    active: true,
    trigger_condition: "Al guardar una nota de voz",
    action_result: "→ Resumir y proponer una categoría.",
    confirmation_note: "Tú confirmas dónde guardarla.",
    icon_name: "mic-rule",
    position: 1
  },
  {
    title: "Un paso, no una lista infinita",
    active: true,
    trigger_condition: "Al organizar una idea de Proyectos",
    action_result: "→ Sugerir hasta 3 próximos pasos.",
    confirmation_note: "Solo se añaden si los confirmas.",
    icon_name: "list-checks",
    position: 2
  },
  {
    title: "El mes, bajo control",
    active: false,
    trigger_condition: "Al llegar al 80 % del presupuesto",
    action_result: "→ Mostrar un aviso en la app.",
    confirmation_note: "No mueve dinero ni cambia límites.",
    icon_name: "wallet",
    position: 3
  }
])
