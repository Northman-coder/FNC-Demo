class TaxSetting < ApplicationRecord
  REGIONS = %w[uk us europe international].freeze

  EUROPE_COUNTRY_CODES = %w[
    AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE
    IS LI NO CH
  ].freeze

  EUROPE_COUNTRY_NAMES = %w[
    austria belgium bulgaria croatia cyprus czechia czech-republic denmark estonia finland france
    germany greece hungary ireland italy latvia lithuania luxembourg malta netherlands poland portugal
    romania slovakia slovenia spain sweden
    iceland liechtenstein norway switzerland
  ].freeze

  UK_ALIASES = ["uk", "u.k", "united kingdom", "great britain", "gb", "gbr", "england", "scotland", "wales", "northern ireland"].freeze
  US_ALIASES = ["us", "u.s", "usa", "u.s.a", "united states", "united states of america"].freeze

  validates :uk_percent, :us_percent, :europe_percent, :international_percent,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def self.current
    first_or_create!
  end

  def region_for_country(country)
    normalized = normalize_country(country)
    return "international" if normalized.blank?

    return "uk" if UK_ALIASES.include?(normalized)
    return "us" if US_ALIASES.include?(normalized)

    code = extract_country_code(normalized)
    return "europe" if code.present? && EUROPE_COUNTRY_CODES.include?(code)

    return "europe" if EUROPE_COUNTRY_NAMES.include?(normalized)

    # fallback name matching (best-effort)
    return "europe" if normalized.include?("europe")

    "international"
  end

  def percent_for_region(region)
    case region.to_s
    when "uk" then uk_percent
    when "us" then us_percent
    when "europe" then europe_percent
    else international_percent
    end
  end

  def percent_for_country(country)
    percent_for_region(region_for_country(country))
  end

  private

  def normalize_country(country)
    country.to_s.strip.downcase
  end

  def extract_country_code(normalized)
    # If user stores ISO2 codes like "DE" or "de", treat that as the code.
    return normalized.upcase if normalized.match?(/\A[a-z]{2}\z/)

    # Common patterns like "Germany (DE)" or "DE - Germany"
    m = normalized.match(/\b([a-z]{2})\b/)
    m ? m[1].upcase : nil
  end
end
