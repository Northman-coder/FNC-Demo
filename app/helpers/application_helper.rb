module ApplicationHelper
	include Pagy::Frontend

	def homepage_section(identifier)
		@homepage_sections ||= {}
		@homepage_sections[identifier] ||= HomepageSection.find_or_create(identifier)
	end

	def homepage_section_text(identifier, attribute, fallback: nil)
		section = homepage_section(identifier)
		value = section.public_send(attribute).presence
		value || fallback
	end

	def free_shipping_threshold_display
		homepage_section_text("free_shipping", :label, fallback: "£60")
	end

	def free_shipping_threshold_amount
		display = free_shipping_threshold_display.to_s
		number = display.scan(/[\d,.]+/).first
		return 60.to_d if number.blank?

		BigDecimal(number.delete(","))
	rescue ArgumentError
		60.to_d
	end
end
