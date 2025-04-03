module CollectionBuilderGenerateDerivatives
  Jekyll::Hooks.register(:site, :after_init, priority: :low) do |site|
    if site.config['generate-derivatives-on-build'] == true
      require 'rake'
      load 'rakelib/generate_derivatives.rake'
      config_args = site.config['generate-derivatives-arguments']
      config_args = {} unless config_args

      thumbs_size = config_args['thumbs_size'] ? config_args['thumbs_size'] : '450x'
      small_size = config_args['small_size'] ? config_args['small_size'] : '800x800'
      density = config_args['density'] ? config_args['density'] : '300'
      missing = 'true'
      compress_originals= 'false'
      input_dir = config_args['input_dir'] ? config_args['input_dir'] : '300'
      Rake::Task['generate_derivatives'].invoke(thumbs_size, small_size, density, missing, compress_originals, input_dir)
    end
  end
end