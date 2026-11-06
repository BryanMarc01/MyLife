class IdeaOrganizerService
  DEFAULT_TRANSCRIPT = "«Podría crear una newsletter de paseos por Madrid. Una ruta corta, un café y una librería cada viernes. Empezar por Malasaña.»".freeze

  Proposal = Data.define(:title, :category, :status_tag, :summary, :essential_summary, :first_step, :steps, :icon_name)

  def self.propose(raw_text)
    new(raw_text).propose
  end

  def initialize(raw_text)
    @raw_text = raw_text.to_s.strip
  end

  def propose
    clean = @raw_text.gsub(/[«»"]/, "").strip
    if clean.blank?
      return Proposal.new(
        title: "",
        category: "Proyectos",
        status_tag: "Por explorar",
        summary: "Pendiente de transcripción",
        essential_summary: "",
        first_step: "Habla o escribe tu idea arriba para ver la propuesta de organización.",
        steps: [],
        icon_name: "route"
      )
    end

    if clean.downcase.include?("newsletter") || clean.downcase.include?("paseos")
      return Proposal.new(
        title: "Newsletter de paseos",
        category: "Proyectos",
        status_tag: "Por explorar",
        summary: "Una ruta, un café y una librería.",
        essential_summary: "Una newsletter semanal para descubrir Madrid a pie: una ruta corta, un café y una librería cada viernes.",
        first_step: "Primer paso sugerido: dibujar una ruta por Malasaña.",
        steps: [
          "Dibujar una ruta por Malasaña",
          "Elegir un café y una librería",
          "Preparar el primer borrador"
        ],
        icon_name: "route"
      )
    end

    category = infer_category(clean)
    icon_name = infer_icon(clean, category)
    sentences = clean.split(/[\.\!\?]+/).map(&:strip).reject(&:blank?)
    title = extract_title(sentences.first || clean)
    summary = sentences[1] ? "#{sentences[1]}." : "#{clean.truncate(48)}"
    first_step_action = sentences.last && sentences.size > 1 ? sentences.last.downcase : "definir el primer paso para #{title.downcase}"

    steps = [
      first_step_action.upcase_first,
      "Dedicar 15 minutos a bocetar la idea",
      "Revisar materiales o recursos necesarios"
    ]

    Proposal.new(
      title: title,
      category: category,
      status_tag: "Por explorar",
      summary: summary,
      essential_summary: clean.end_with?(".") ? clean : "#{clean}.",
      first_step: "Primer paso sugerido: #{first_step_action}.",
      steps: steps,
      icon_name: icon_name
    )
  end

  private

  def infer_category(text)
    down = text.downcase
    if down.match?(/receta|menú|menu|compra|casa|semana|cocina|rutina/)
      "Vida diaria"
    elsif down.match?(/leer|libro|taller|cerámica|descanso|rincón|viaje|salud/)
      "Personal"
    else
      "Proyectos"
    end
  end

  def infer_icon(text, category)
    down = text.downcase
    return "utensils" if category == "Vida diaria" || down.match?(/comida|receta|menú|menu/)
    return "book-open" if down.match?(/leer|libro|lectura/)
    return "coffee" if category == "Personal"
    "route"
  end

  def extract_title(first_sentence)
    cleaned = first_sentence
      .sub(/\A(podría|quiero|debería|me gustaría|idea para|crear una|crear un|hacer una|hacer un)\s+/i, "")
      .sub(/\s+por\s+\w+\z/i, "")
      .strip
    cleaned.upcase_first.truncate(34, omission: "")
  end
end
