# frozen_string_literal: true
require 'i18n/backend/fallbacks'

module Dato
  module Utils
    module LocaleValue
      def self.find(obj)
        locale_with_value = I18n.fallbacks[I18n.locale]
                                .find { |locale| obj[locale] }

        obj[locale_with_value || I18n.locale]
      end
    end
  end
end
