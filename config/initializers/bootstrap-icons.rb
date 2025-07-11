# config/initializers/bootstrap_icons.rb
BOOTSTRAP_CUSTOM_ICON_LIST = begin
  path = Rails.root.join("app/assets/stylesheets/bootstrap-icons.scss")
  content = File.read(path)

  # Extract icon names in order of appearance
  all_icons = content.scan(/"([^"]+)"\s*:/).flatten

  # Get everything after "anchor", "anchor" is the first of custom icons
  anchor_index = all_icons.index("anchor")
  anchor_index ? all_icons[(anchor_index + 1)..-1] : []
end
