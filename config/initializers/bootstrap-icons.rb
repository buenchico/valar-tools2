# config/initializers/bootstrap_icons.rb
scss_path = Rails.root.join("app/assets/stylesheets/bootstrap-icons.scss")

variable_name = '$bootstrap-icons-extra-list'

content = File.read(scss_path)

# Match the SCSS variable list
match = content.match(/#{Regexp.escape(variable_name)}:\s*\(([^)]+)\)/)
if match
  raw_list = match[1]
  icons = raw_list.split(',').map { |s| s.strip.delete('"').delete("'") }
  BOOTSTRAP_CUSTOM_ICON_LIST = icons
else
  BOOTSTRAP_CUSTOM_ICON_LIST = []
end
