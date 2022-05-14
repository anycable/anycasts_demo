# frozen_string_literal: true

Turbo::StreamsChannel.singleton_class.prepend(Module.new do
  def broadcast_render_to(...)
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        super(locale, ...)
      end
    end
  end

  def broadcast_action_to(...)
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        super(locale, ...)
      end
    end
  end
end)
