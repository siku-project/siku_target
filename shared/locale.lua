TargetLocale = {}

--- The language the resource runs in, as configured.
---@return string language The language code.
function TargetLocale.language()
  return TranslationConfig.language
end

--- The interface strings of the running language, the `web` block of
--- translations/<language>.lua. They travel to the interface at startup so
--- a server owner edits one file and never rebuilds for a wording change.
---@return table web The strings by key, empty when the block is missing.
function TargetLocale.web()
  local translations <const> = Siku.locale.translations()
  local web <const> = type(translations) == 'table' and translations.web or nil

  if type(web) ~= 'table' then
    return {}
  end

  return web
end

--- What the interface needs to run in the right language.
---@return table locale { language, translations = { web } }.
function TargetLocale.describe()
  return {
    language = TargetLocale.language(),
    translations = { web = TargetLocale.web() },
  }
end
