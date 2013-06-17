
namespace :i18n do
  
  desc "Find and list translation keys that do not exist in all locales"
  task :missing_keys => :environment do
    finder = LocalchI18n::MissingKeysFinder.new(I18n.backend)
    finder.find_missing_keys
  end
  
  desc "Download translations from Google Spreadsheet and save them to YAML files."
  task :import_translations => :environment do
    raise "'Rails' not found! Tasks can only run within a Rails application!" if !defined?(Rails) && ENV['config_root'].nil?

    config_root = ENV['config_root'] || Rails.root.join('config')
    config_file = "#{config_root}translations.yml"
    raise "No config file '#{config_file}' found." if !File.exists?(config_file)

    tmp_dir = ENV['config_root'] ? "#{ENV['config_root']}tmp" : Rails.root.join('tmp')

    translations = LocalchI18n::Translations.new(config_file, tmp_dir)
    translations.download_files
    translations.store_translations
    translations.clean_up
    
  end
  
  desc "Export all language files to CSV files (only files contained in en folder are considered)"
  task :export_translations => :environment do

    raise "'Rails' not found! Tasks can only run within a Rails application!" if !defined?(Rails) && ENV['translations_root']

    locales     = I18n.available_locales
    main_locale = ENV['main_locale'] || locales.first.to_s
    source_dir  = ENV['translations_root'] || Rails.root.join('config', 'locales', main_locale)
    output_dir  = ENV['translations_root'] ? "#{ENV['translations_root']}tmp" : Rails.root.join('tmp')

    input_files = Dir[File.join(source_dir, '**', '*.yml')]

    puts ""
    puts "  Detected locales: #{locales}"
    puts "  Detected files:"
    input_files.each {|f| puts "    * #{File.basename(f)}" }
    
    puts ""
    puts "  Start exporting files:"
    
    input_files.each do |file|
      exporter = LocalchI18n::TranslationFileExport.new(source_dir, file, output_dir, locales, main_locale)
      exporter.export
    end
    
    puts ""
    puts "  CSV files can be removed safely after uploading them manually to Google Spreadsheet."
    puts ""
  end
  
end


