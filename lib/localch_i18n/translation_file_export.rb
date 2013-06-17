module LocalchI18n
  class TranslationFileExport
    
    attr_accessor :translations

    def initialize(source_dir, source_file, output_dir, locales, main_locale = nil)
      @source_dir = source_dir
      @source_file = source_file
      @locales = locales.map {|l| l.to_s.downcase }
      @main_locale = main_locale || (@locales.include?('en') ? 'en' : @locales.first)
      @output_file = File.join(output_dir, source_file.gsub('.yml', '.csv').gsub(source_dir, '').gsub('/', '_'))

      @translations = {}
    end
    
    
    def export
      load_translations
      write_to_csv
    end
    
    
    def write_to_csv

      puts "    #{@source_file}: write CSV to '#{@output_file}' \n\n"

      FileUtils.mkdir_p File.dirname(@output_file)
      CSV.open(@output_file, "wb") do |csv|
        csv << (["key"] + @locales)

        @translations[@main_locale].keys.each do |key|
          values = @locales.map do |locale|
            @translations[locale][key]
          end
          csv << values.unshift(key)
        end
      end
      
    end
    
    
    def load_translations
      @locales.each do |locale|
        translation_hash = load_language(locale)
        @translations[locale] = flatten_translations_hash(translation_hash)
      end
    end
    
    def load_language(locale)
      
      puts "    #{@source_file}: load translations for '#{locale}'"

      input_file = @source_file
      translations = {}
      translations = YAML.load_file(input_file) if File.exists?(input_file)
      translations[locale]
    end
    
    def flatten_translations_hash(translations, parent_key = [])
      flat_hash = {}
      
      translations.each do |key, t|
        current_key = parent_key.dup << key
        if t.is_a?(Hash)
          # descend
          flat_hash.merge!(flatten_translations_hash(t, current_key))
        else
          # leaf -> store as value for key
          flat_hash[current_key.join('.')] = t
        end
      end unless translations.nil?

      flat_hash
    end
    
  end

end
