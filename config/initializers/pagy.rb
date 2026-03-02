# frozen_string_literal: true

# Pagy initializer
#
# Minimal setup: backend/frontend modules are included in ApplicationController
# and ApplicationHelper.

# Avoid 404/exception for out-of-range pages (e.g. user requests ?page=9999)
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

Pagy::DEFAULT[:items] = 24
