module CafeCar
  # A status-ish value as a colored pill. Attributes reach it by convention —
  # `FieldInfo#badge?` (an ActiveRecord enum, or a string status/state column)
  # routes them here from `Presenter#show` — or explicitly with `as: :badge`.
  # The style (a Badge flag like `:success`) comes from the locale under
  # `badge.styles`, the same convention as `bulk_actions.styles`, with shipped
  # defaults; unlisted values render the neutral badge.
  class BadgePresenter < self[:Presenter]
    def style = t("badge.styles.#{object}", default: nil)&.to_sym
    def label = t(object.to_s, default: object.to_s.humanize)

    def to_html
      return blank if object.blank?
      ui.Badge(*style, label)
    end
  end
end
