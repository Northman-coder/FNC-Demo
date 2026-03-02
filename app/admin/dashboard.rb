# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "px-4 py-12 md:py-20 text-center m-auto max-w-3xl" do
      h2 "Welcome to ActiveAdmin", class: "text-base font-semibold leading-7 text-indigo-600 dark:text-indigo-500"
      para "Quick actions", class: "mt-2 text-3xl sm:text-4xl font-bold text-gray-900 dark:text-gray-200"

      para class: "mt-6 text-lg leading-8 text-gray-700 dark:text-gray-400" do
        text_node "Edit footer text and the free-shipping threshold used on the homepage: "
        span do
          text_node link_to("Homepage & Footer Content", admin_homepage_sections_path, class: "text-indigo-600 dark:text-indigo-400 underline")
        end
      end
    end
  end
end
