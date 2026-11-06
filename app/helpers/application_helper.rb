module ApplicationHelper
  def bpa_icon(name, size: 22, stroke_width: 1.8)
    paths = case name.to_s
            when "home"
              '<path d="m3 11 9-8 9 8" /><path d="M5.5 9.5V21h13V9.5" /><path d="M9.5 21v-6h5v6" />'
            when "bulb"
              '<path d="M9 18h6" /><path d="M10 22h4" /><path d="M8.2 14.5A7 7 0 1 1 15.8 14.5c-.8.6-.8 1.3-.8 1.5H9c0-.2 0-.9-.8-1.5Z" />'
            when "check"
              '<circle cx="12" cy="12" r="9" /><path d="m8 12 2.5 2.5L16 9" />'
            when "wallet"
              '<path d="M4 6.5A2.5 2.5 0 0 1 6.5 4H19v16H6.5A2.5 2.5 0 0 1 4 17.5Z" /><path d="M4 7h15" /><path d="M15 11h6v5h-6a2.5 2.5 0 0 1 0-5Z" />'
            when "plus"
              '<path d="M12 5v14" /><path d="M5 12h14" />'
            when "spark"
              '<path d="m12 3 1.3 4.1a5 5 0 0 0 3.2 3.2l4.1 1.3-4.1 1.3a5 5 0 0 0-3.2 3.2L12 20.2l-1.3-4.1a5 5 0 0 0-3.2-3.2l-4.1-1.3 4.1-1.3a5 5 0 0 0 3.2-3.2Z" />'
            when "arrow"
              '<path d="M5 12h14" /><path d="m14 7 5 5-5 5" />'
            when "close"
              '<path d="m6 6 12 12" /><path d="M18 6 6 18" />'
            when "trash"
              '<path d="M4 7h16" /><path d="M9 3h6l1 4H8Z" /><path d="m6.5 7 .7 14h9.6l.7-14" />'
            when "mic"
              '<path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z" /><path d="M19 10v2a7 7 0 0 1-14 0v-2" /><line x1="12" x2="12" y1="19" y2="22" />'
            else
              ""
            end

    %(<svg width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="#{stroke_width}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">#{paths}</svg>).html_safe
  end

  def format_bpa_money(cents)
    euros = cents.to_f / 100.0
    sign = euros.negative? ? "-" : ""
    abs_val = euros.abs
    whole, dec = format("%.2f", abs_val).split(".")
    whole_with_dots = whole.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    "#{sign}#{whole_with_dots},#{dec} €"
  end
end
