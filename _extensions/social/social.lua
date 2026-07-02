--- RevealJS Social - Filter
--- @module "social"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @brief Pandoc AST filter for social.
--- @description Adds Open Graph and Twitter (X) social-card <meta> tags to the
--- <head> of RevealJS presentations, reading standard Quarto social metadata
--- (open-graph, twitter-card, title, description, image, site-url) and falling
--- back to scoped extensions.social options.

--- Extension name constant
local EXTENSION_NAME = 'social'

local str = require(quarto.utils.resolve_path('_modules/string.lua'):gsub('%.lua$', ''))
local log = require(quarto.utils.resolve_path('_modules/logging.lua'):gsub('%.lua$', ''))
local meta_mod = require(quarto.utils.resolve_path('_modules/metadata.lua'):gsub('%.lua$', ''))

--- Map of lowercase image file extensions to their IANA media types.
--- @type table<string, string>
local IMAGE_MEDIA_TYPES = {
  png = 'image/png',
  jpg = 'image/jpeg',
  jpeg = 'image/jpeg',
  gif = 'image/gif',
  webp = 'image/webp',
  svg = 'image/svg+xml'
}

--- Read a nested value from a metadata table following a key path.
--- Returns nil for missing paths, boolean nodes (e.g. `open-graph: true`),
--- and empty values.
--- @param meta table The document metadata table
--- @param path table<integer, string> The ordered key path (e.g. {'open-graph', 'image'})
--- @return string|nil The stringified value, or nil
local function meta_path(meta, path)
  local node = meta
  for _, key in ipairs(path) do
    if type(node) ~= 'table' then return nil end
    node = node[key]
    if node == nil then return nil end
  end
  if type(node) == 'boolean' then return nil end
  local value = str.stringify(node)
  if str.is_empty(value) then return nil end
  return value
end

--- Resolve a value from standard Quarto metadata paths, falling back to the
--- scoped extensions.social option.
--- @param meta table The document metadata table
--- @param standard_paths table<integer, table<integer, string>> Ordered list of key paths to try first
--- @param scoped_key string|nil The extensions.social key used as fallback
--- @return string|nil The resolved value, or nil
local function resolve(meta, standard_paths, scoped_key)
  for _, path in ipairs(standard_paths) do
    local value = meta_path(meta, path)
    if value then return value end
  end
  if scoped_key then
    return meta_mod.get_metadata_value(meta, EXTENSION_NAME, scoped_key)
  end
  return nil
end

--- Check whether a URL is absolute (http(s) or data URI).
--- @param url string The URL to test
--- @return boolean True if the URL is absolute
local function is_absolute_url(url)
  return url:match('^https?://') ~= nil or url:match('^data:') ~= nil
end

--- Join a base URL and a relative path with a single separating slash.
--- @param base string The base URL
--- @param relative string The relative path
--- @return string The joined URL
local function join_url(base, relative)
  return (base:gsub('/+$', '')) .. '/' .. (relative:gsub('^/+', ''))
end

--- Resolve a document- or project-relative path to an absolute filesystem path.
--- Follows Quarto's path convention: a leading "/" anchors the path to the
--- project root; any other relative path is resolved against the input file's
--- directory. `quarto.doc.add_resource` otherwise resolves relative paths
--- against the calling Lua script's directory, so an absolute path is required
--- for the resource to be found and copied to the matching output location.
--- @param path string The document- or project-relative path
--- @return string The absolute filesystem path
local function document_resource_path(path)
  local project_dir = quarto.project.directory
  if project_dir and path:match('^/') then
    return pandoc.path.join({ project_dir, (path:gsub('^/+', '')) })
  end
  local input_dir = pandoc.path.directory(quarto.doc.input_file)
  return pandoc.path.join({ input_dir, path })
end

--- Infer the IANA media type from an image path extension.
--- @param image string The image path or URL
--- @return string|nil The media type, or nil when it cannot be inferred
local function infer_image_type(image)
  local ext = image:match('%.([%a%d]+)$')
  if not ext then return nil end
  return IMAGE_MEDIA_TYPES[ext:lower()]
end

--- Process the whole document: resolve social metadata, inject <meta> tags into
--- the <head>, and ensure a local image is copied on publish.
--- @param doc pandoc.Pandoc The document being processed
--- @return pandoc.Pandoc The (possibly extended) document
local function process_document(doc)
  if not quarto.doc.is_format('revealjs') then
    return doc
  end

  local meta = doc.meta

  if meta_mod.get_metadata_value(meta, EXTENSION_NAME, 'enabled') == 'false' then
    return doc
  end

  local title = resolve(meta, { { 'open-graph', 'title' }, { 'twitter-card', 'title' }, { 'title' } }, 'title')
  local description = resolve(
    meta,
    { { 'open-graph', 'description' }, { 'twitter-card', 'description' }, { 'description' } },
    'description'
  )
  local site_name = resolve(meta, { { 'open-graph', 'site-name' } }, 'site-name')
  local og_type = resolve(meta, {}, 'type') or 'website'
  local locale = resolve(meta, { { 'open-graph', 'locale' }, { 'lang' } }, 'locale')
  local image = resolve(meta, { { 'open-graph', 'image' }, { 'twitter-card', 'image' }, { 'image' } }, 'image')
  local image_width = resolve(meta, { { 'open-graph', 'image-width' } }, 'image-width')
  local image_height = resolve(meta, { { 'open-graph', 'image-height' } }, 'image-height')
  local image_alt = resolve(meta, { { 'open-graph', 'image-alt' } }, 'image-alt')
  local image_type = resolve(meta, {}, 'image-type')
  local card_style = resolve(meta, { { 'twitter-card', 'card-style' } }, 'card-style')
  local twitter_site = resolve(meta, { { 'twitter-card', 'site' } }, 'twitter-site')
  local twitter_creator = resolve(meta, { { 'twitter-card', 'creator' } }, 'twitter-creator')
  local site_url = resolve(meta, { { 'site-url' } }, 'site-url')
  local url = resolve(meta, {}, 'url') or site_url

  --- @type string|nil Absolute image URL emitted in the meta tags
  local image_url = image
  if image and not is_absolute_url(image) then
    if site_url then
      image_url = join_url(site_url, image)
    else
      log.log_warning(
        EXTENSION_NAME,
        "Image '" .. image .. "' is a relative path and no 'site-url' is set. " ..
        "Social scrapers require an absolute URL for 'og:image'; set 'site-url' " ..
        "or provide an absolute image URL."
      )
    end
  end

  if image and not image_type then
    image_type = infer_image_type(image)
  end

  local twitter_card = card_style or (image and 'summary_large_image' or 'summary')

  --- @type table<integer, string> Accumulated <meta> tag strings
  local head_lines = {}

  --- Append a <meta> tag when the value is non-empty.
  --- @param kind string The attribute kind ("name" or "property")
  --- @param key string The tag key (e.g. "og:title")
  --- @param value string|nil The tag content
  --- @return nil
  local function add_meta(kind, key, value)
    if str.is_empty(value) then return end
    head_lines[#head_lines + 1] = string.format(
      '<meta %s="%s" content="%s">',
      kind,
      str.escape_attribute(key),
      str.escape_attribute(value)
    )
  end

  add_meta('name', 'description', description)
  add_meta('property', 'og:type', og_type)
  add_meta('property', 'og:site_name', site_name)
  add_meta('property', 'og:title', title)
  add_meta('property', 'og:description', description)
  add_meta('property', 'og:url', url)
  add_meta('property', 'og:locale', locale)
  add_meta('property', 'og:image', image_url)
  if image_url and image_url:match('^https://') then
    add_meta('property', 'og:image:secure_url', image_url)
  end
  add_meta('property', 'og:image:type', image_type)
  add_meta('property', 'og:image:width', image_width)
  add_meta('property', 'og:image:height', image_height)
  add_meta('property', 'og:image:alt', image_alt)
  add_meta('name', 'twitter:card', twitter_card)
  add_meta('name', 'twitter:site', twitter_site)
  add_meta('name', 'twitter:creator', twitter_creator)
  add_meta('name', 'twitter:title', title)
  add_meta('name', 'twitter:description', description)
  add_meta('name', 'twitter:image', image_url)
  add_meta('name', 'twitter:image:alt', image_alt)

  if #head_lines > 0 then
    quarto.doc.include_text('in-header', table.concat(head_lines, '\n'))
  end

  if image and not is_absolute_url(image) then
    quarto.doc.add_resource(document_resource_path(image))
  end

  return doc
end

return {
  { Pandoc = process_document }
}
